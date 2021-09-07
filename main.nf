nextflow.enable.dsl = 2


process coding {
    container 'nanozoo/prodigal:2.6.3--2769024'
    // Some genomes might have been corrupted during download
    errorStrategy 'ignore'
    cpus 1

    input:
        tuple(val(name), path(genome))

    output:
        tuple(val(name), path('coding.faa'))

    """
    gunzip -c ${genome} > tmp
    prodigal -q -i tmp -a coding.faa > /dev/null
    """
}


process annotate {
    publishDir "${params.results}/virulence", mode: 'copy', overwrite: true
    container "soedinglab/mmseqs2"
    cpus 4

    input:
        tuple(val(name), path(proteins), path(db))

    output:
        tuple(val(name), path("${name}.m8"))

    """
    mmseqs easy-search --threads ${task.cpus} --min-seq-id 0.9 -c 0.7 --max-accept 1 ${proteins} targets ${name}.m8 tmp
    """

}


process index {
    container 'soedinglab/mmseqs2'
    cpus "${params.max_cpus}"

    input:
        path(db)

    output:
        path('targets*')

    """
    mmseqs createdb --dbtype 1 ${db} targets
    mmseqs createindex --threads ${task.cpus} --headers-split-mode 1 targets tmp
    """
}


process prokka {
    publishDir "${params.results}/annotation", mode: 'copy', overwrite: true
    container 'nanozoo/prokka:1.14.6--c99ff65'
    cpus 4

    input:
        tuple(val(name), path(proteins))

    output:
        tuple(val(name), path("annotation/${name}.gff"))

    """
    prokka --mincontiglen 2000 --cpus ${task.cpus} --prefix ${name} --outdir annotation
    """
}


workflow {

    // Channels
    db = channel.fromPath(params.db)
    genomes = channel.fromPath(params.genomes)
                     .splitCsv(header: false)
                     .map{ fp -> tuple(fp.simpleName, fp) }

    // Action
    coding(genomes)
    index(db)

    // annotate(coding.out.combine(index.out.toList()))

    prokka(coding)
}

