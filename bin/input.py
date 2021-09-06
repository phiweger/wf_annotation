#! /usr/bin/env python


'''
Given a folder and a wildcard, generate an input csv and a backtranslation table.
'''


import argparse
from glob import glob
from pathlib import Path
from uuid import uuid4


def get_parser():
    '''
    https://gist.github.com/linuxluigi/0613c2c699d16cb5e171b063c266c3ad
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-i', required=True,
        help='Input folder')
    parser.add_argument(
        '-p', required=True,
        help='Wildcard')
    parser.add_argument(
        '-o', required=True,
        help='Outfile')
    return parser


def main(args=None):
    parser = get_parser()
    args = parser.parse_args(args)

    with open(args.o, 'w+') as out:
        for i in Path(args.i).glob(args.p):
            out.write(f'{uuid4().__str__()},{i.__str__()}\n')


if __name__ == '__main__':
    main()
