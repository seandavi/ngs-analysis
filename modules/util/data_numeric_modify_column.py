#!/usr/bin/env python
description = '''
Modify a column in a data file, i.e. add a number or multiply by a number
The data file's columnar values are considered to be the first operand, and the value inputted as an option is considered to be the second operand
'''

import argparse
import sys

def operation_add(p1, p2):
    return float(p1) + float(p2)

def operation_mult(p1, p2):
    return float(p1) * float(p2)

def set_precision(val, precision):
    '''
    Round value to the given precision decimal, and return the value as a string
    '''
    formatstr = '%.' + str(precision) + 'f'
    return formatstr % val

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file',
                    help='Input file',
                    nargs='?',
                    type=argparse.FileType('r'), default=sys.stdin)
    ap.add_argument('-k', '--column',
                    help='Column number, first column number is 0',
                    type=int,
                    default=0)
    ap.add_argument('-t', '--operation-type',
                    help='Type of operation to perform on the values of the data column',
                    choices=['add', 'mult'],
                    default='add')
    ap.add_argument('-v','--operand-value',
                    help='The value to use as the second operand in the operation',
                    type=float,
                    default=1.0)
    ap.add_argument('-p', '--precision',
                    help='The number of decimal places to round to.  If zero, then the values will be converted to integer',
                    type=int,
                    default=0)
    ap.add_argument('--header-row',
                    help='File contains header row, which must be skipped',
                    action='store_true')
    params = ap.parse_args()

    if params.operation_type == 'add':
        operation_fnc = operation_add
    elif params.operation_type == 'mult':
        operation_fnc = operation_mult

    for i,line in enumerate(params.file):
        if i == 0 and params.header_row:
            sys.stdout.write(line)
            continue
        
        la = line.strip().split('\t')
        la[params.column] = set_precision(operation_fnc(la[params.column], params.operand_value), params.precision)
        sys.stdout.write('%s\n' % '\t'.join(la))

    params.file.close()


if __name__ == '__main__':
    main()
