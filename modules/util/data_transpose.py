#!/usr/bin/env python
description = """
Read in a matrix and output the transpose of the matrix
Note: Reads in entire file to memory, so file should not be too large
"""

import argparse
import sys

def main():
    # Set up the parameter(argument) options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('infile', help='File containing matrix data', nargs='?', type=argparse.FileType('r'), default=sys.stdin)
    ap.add_argument('-o', '--outfile', help='File to output data to.  Default: Stdout', type=argparse.FileType('w'), default=sys.stdout)
    ap.add_argument('-d', '--delim', help='Column delimiter', type=str, default='\t')
    params = ap.parse_args()

    # Read in the file
    dat = []
    for line in params.infile:
        la = line.strip().split(params.delim)
        dat.append(la)
    params.infile.close()
    
    # Take the transpose, and output
    dat_t = zip(*dat)
    for row in dat_t:
        params.outfile.write(params.delim.join(row) + '\n')

    # Close outfile handle
    params.outfile.close()


if __name__ == '__main__':
    main()
