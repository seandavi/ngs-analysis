#!/usr/bin/env python
description = '''
Read in tabular data, and generate a dictionary from the specified columns.
Save the dictionary to file as a pickle.

Uses tuple for multiple key columns
Uses list for multiple value columns
'''

import argparse
import cPickle
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('infile',
                    help='Input tabular file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('outfile',
                    help='Output .pkl file',
                    type=argparse.FileType('w'))
    ap.add_argument('-k', '--key-columns',
                    nargs='+',
                    help='Columns to be used as dict keys, 0-based',
                    type=int,
                    default=[0])
    ap.add_argument('-v', '--value-columns',
                    nargs='+',
                    help='Columns to be used as dict values, 0-based',
                    type=int,
                    default=[1])
    ap.add_argument('-p', '--skip-header',
                    help='Skip the topmost row, which is the header line',
                    action='store_true')
                    
                    
    params = ap.parse_args()

    # Build dictionary
    d = {}
    with params.infile as fin:
        # Skip header line
        if params.skip_header:
            fin.next()
        
        for line in fin:
            cols = line.strip('\n').split('\t')

            # Get the key
            if len(params.key_columns) == 1:
                key = cols[params.key_columns[0]]
            else:
                key = tuple([cols[_i] for _i in params.key_columns])

            # Get the value
            if len(params.value_columns) == 1:
                value = cols[params.value_columns[0]]
            else:
                value = [cols[_i] for _i in params.value_columns]

            d[key] = value

    # Pickle the dict
    with params.outfile as fo:
        cPickle.dump(d, fo, cPickle.HIGHEST_PROTOCOL)
    


if __name__ == '__main__':
    main()
