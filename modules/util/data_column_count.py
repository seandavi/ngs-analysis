#!/usr/bin/env python

description = '''
Read in a file, and generate a report on the number of columns in each line
'''

import argparse
import sys

def count_columns(fi, delim=None):
    '''
    Read through each row of the file input stream, and count
    the number of columns.
    '''
    colcount2freq = {}
    colcount2linenum = {}
    i = 0
    for line in fi:
        i += 1
        colcount = len(line.strip('\n').split(delim))
        if colcount not in colcount2freq:
            colcount2freq[colcount] = 0
        colcount2freq[colcount] += 1
        if colcount not in colcount2linenum:
            colcount2linenum[colcount] = set()
        
        if len(colcount2linenum[colcount]) < 3:
            colcount2linenum[colcount].add(i)

    # Check if line count is unique
    colcounts = sorted(colcount2freq.keys(), key=lambda x: colcount2freq[x], reverse=True)
    len_colcounts = len(colcounts)
    if len_colcounts == 1:
        sys.stdout.write('Number of columns: %i\n' % colcounts[0])
        return
    
    # Multiple colcounts
    sys.stdout.write('%s\n' % '\t'.join(['col-count', 'freq', 'percent', 'occurs-at']))
    for cc in colcounts:
        percentage = colcount2freq[cc] / float(i)
        sys.stdout.write('%i\t%i\t%.3f' % (cc, colcount2freq[cc], percentage))
        if percentage < 0.90:
            line_numbers = [str(x) for x in colcount2linenum[cc]]
            sys.stdout.write('\tlines: %s' % ', '.join(line_numbers))
        sys.stdout.write('\n')

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file',
                    help='Input file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-d', '--delim',
                    help='File delimiter',
                    type=str,
                    default=None)
    params = ap.parse_args()

    # Generate the report
    count_columns(params.file, params.delim)
    params.file.close()


if __name__ == '__main__':
    main()
