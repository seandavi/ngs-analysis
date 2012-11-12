#!/usr/bin/env python
description = """
Read in a matrix and output the transpose of the matrix
"""

import argparse
import itertools
import sys

def main():
    # Set up the parameter(argument) options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('infile', help='File containing matrix data', nargs='?', type=argparse.FileType('r'), default=sys.stdin)
    ap.add_argument('-o', '--outfile', help='File to output data to.  Default: Stdout', type=argparse.FileType('w'), default=sys.stdout)
    params = ap.parse_args()

    with params.infile as f:
        for row in itertools.izip(*(line.strip('\n').split('\t') for line in f)):
            params.outfile.write('%s\n' % '\t'.join(row))

if __name__ == '__main__':
    main()
