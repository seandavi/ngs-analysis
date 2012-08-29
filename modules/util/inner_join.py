#!/usr/bin/env python
description = '''
Read 2 files, and inner join them.  The files should be tab-delimited.
The order of the output rows will be based on file1.
The output file will be in the following format:
(file1row,file2row) separated by tabs
For optimal performance, the input files should be unique.
'''

import argparse
import sys

def main():
    # Set up cli argument options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file1', 
                    help='Input file 1',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('file2', 
                    help='Input file 2',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    # Optional arguments
    ap.add_argument('--k1',
                    help='Key column of file 1, 0-based',
                    type=int,
                    default=0)
    ap.add_argument('--k2',
                    help='Key column of file 2, 0-based',
                    type=int,
                    default=0)
    ap.add_argument('--header',
                    help='Header line exists for the input files',
                    action='store_true')
    ap.add_argument('-o', '--outfile',
                    help='Output file',
                    nargs='?',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()

    # Read file2 into memory
    file2_key2line = {}
    for i,line in enumerate(params.file2):
        line_stripped = line.strip('\n')

        # Header line
        if i == 0 and params.header:
            file2_header = line_stripped
            continue
        
        key = line_stripped.split('\t')[params.k2]

        if key not in file2_key2line:
            file2_key2line[key] = set()
        file2_key2line[key].add(line_stripped)

    # Read file 1, and output results as matching keys are found
    for i,line in enumerate(params.file1):
        line_stripped = line.strip('\n')

        # Header line
        if i == 0 and params.header:
            params.outfile.write('%s\n' % '\t'.join([line_stripped, file2_header]))
            continue
        
        key = line_stripped.split('\t')[params.k1]
        if key in file2_key2line:
            for file2_line in file2_key2line[key]:
                params.outfile.write('%s\n' % '\t'.join([line_stripped, file2_line]))


if __name__ == '__main__':
    main()
