#!/usr/bin/env python
description = '''
Compute the arithmetic sum of the values in a column of data
'''

import argparse
import sys

def add_column(iostream, column, delim=None, weight_col=None):
    accum = 0
    line_number = 1
    for line in iostream:
        line_stripped = line.strip()
        if line_stripped:
            la = line_stripped.split(delim)
            try:
                val = float(la[column])
                # Unweighted
                if weight_col is None:
                    accum += val
                # Weighted
                else:
                    w = float(la[weight_col])
                    accum += (w * val)
                
            except ValueError:
                sys.stderr.write('Warning: Non-numeric value in line %i\n' % line_number)   
        else:
            sys.stderr.write('Warning: Skipping blank line %i\n' % line_number)
        line_number += 1

    return accum

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file', help='Input file', nargs='?', type=argparse.FileType('r'), default=sys.stdin)
    ap.add_argument('-k', '--column', help='Column number, with column count starting with 0', type=int, default=0)
    ap.add_argument('-d', '--delim', help='File column delimiter', type=str, default=None)
    ap.add_argument('-w', '--weight-column', help='Column containing weight coefficients to multiply each value in a row before adding.  I.e. the a\'s in a1x1 + a2x2 + ... + anxn', type=int, default=None)
    params = ap.parse_args()

    # Sum up the data
    column_sum = add_column(params.file, params.column, params.delim, params.weight_column)
    
    # Close file input stream
    params.file.close()
    
    # Print to standard output
    sys.stdout.write('Total Sum: %f\n\n' % column_sum)


if __name__ == '__main__':
    main()
