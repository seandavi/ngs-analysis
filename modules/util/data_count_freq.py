#!/usr/bin/python -tt
description = '''
Read in a data file, and count the number of occurrences for the values
in a specific column of the file.
Output the column values and their counts to standard output
'''

import argparse
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file',
                    help='Input file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-k', '--column',
                    help='Column number (0-based)',
                    type=int,
                    default=0)
    params = ap.parse_args()

    # Read through data file and count the occurrences of the column vals
    val2freq = {}
    for line in params.file:
        la = line.strip().split('\t')
        val = la[params.column]
        if val not in val2freq:
            val2freq[val] = 0
        val2freq[val] += 1
    params.file.close()

    # Print to standard output
    for val,freq in val2freq.iteritems():
        sys.stdout.write('%s\t%i\n' % (val, freq))


if __name__ == '__main__':
    main()
