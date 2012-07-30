#!/usr/bin/env python

description = '''
Read in 2 files, and substitute the values in file 1 column b with file 2 column b, 
using file 1 column a and file 2 column a as the key.

I.e.
File 1
a1    b1    c1
a2    b2    c2
a3    b3    c3


File 2
a1    x1
a2    x2
a3    x3
a4    x4

Result:
a1    x1    c1
a2    x2    c2
a3    x3    c3

For best results, make sure that all of file1 column a is a subset of file2 column a, and
column a in file2 should be unique, i.e. file 2 column a to column b should be many-to-one.
(In another words, file 2 should be a function with column a as the independent variable
and column b as the dependent variable.)
'''

import argparse
import sys

def main():
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
    ap.add_argument('--f1-column-a',
                    help='File 1 column a, zero-based',
                    type=int,
                    default=0)
    ap.add_argument('--f1-column-b',
                    help='File 1 column b, zero-based',
                    type=int,
                    default=1)
    ap.add_argument('--f2-column-a',
                    help='File 2 column a, zero-based',
                    type=int,
                    default=0)
    ap.add_argument('--f2-column-b',
                    help='File 2 column b, zero-based',
                    type=int,
                    default=1)
    params = ap.parse_args()

    # Read file 2 mapping into memory
    f2_a2b = {}
    for line in params.file2:
        la = line.strip().split('\t')
        a = la[params.f2_column_a]
        b = la[params.f2_column_b]
        f2_a2b[a] = b
    params.file2.close()

    # Read in file 1 and substitute the values
    for line in params.file1:
        la = line.strip().split('\t')
        a = la[params.f1_column_a]
        # If key is not in file 2, output error and skip row
        if a not in f2_a2b:
            sys.stderr.write('Could not find key %s in file 2\n' % a)
            continue
        la[params.f1_column_b] = f2_a2b[a]
        sys.stdout.write('%s\n' % '\t'.join(la))

    params.file1.close()


if __name__ == '__main__':
    main()
