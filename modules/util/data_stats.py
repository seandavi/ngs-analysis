#!/usr/bin/env python
#
# Compute basic statistics about the values in a column of data
#

import argparse
import sys
from jjinking.fnc import coldata

def process(iostream_, column):
    avg_, min_, max_ = coldata.basic_statistics(iostream_, iostream=True, col=column)
    output_strings = ['Avg: %s\n' % avg_,
                      'Min: %s\n' % min_,
                      'Max: %s\n' % max_]
    for os_ in output_strings:
        sys.stdout.write(os_)

def main():
    # Set up parameter(argument) options
    ap = argparse.ArgumentParser(description='Compute basic statistics about the values in a column of data')
    ap.add_argument('file', help='Input file', nargs='?', type=argparse.FileType('r'), default=sys.stdin)
    ap.add_argument('-k', '--column', help='Column number, with column count starting with 0', type=int, default=0)
    params = ap.parse_args()

    # Average the data
    process(params.file, params.column)

if __name__ == '__main__':
    main()
