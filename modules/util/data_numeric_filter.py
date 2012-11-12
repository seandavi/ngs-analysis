#!/usr/bin/env python
description='''
Filter columnar data based on set numeric filter, and output resulting
records to standard output
'''

import argparse
import sys

def is_greater_than(left_param, right_param):
    return left_param > right_param

def is_less_than(left_param, right_param):
    return left_param < right_param

def is_greater_than_or_equal(left_param, right_param):
    return left_param >= right_param

def is_less_than_or_equal(left_param, right_param):
    return left_param <= right_param

def is_equal(left_param, right_param):
    return left_param == right_param

def is_true(left_param, right_param):
    return True

def filter_data(fin, column,
                greater_than=None,
                less_than=None,
                equal_to=None):
    '''
    Filter the records (rows) in the input stream fin
    '''

    # Set the comparison operator function
    comparison_op = is_true
    comparison_val = None
    # > or >=
    if greater_than is not None:
        comparison_op = is_greater_than
        comparison_val = greater_than
        if equal_to is not None:
            comparison_op = is_greater_than_or_equal
    # < or <=
    elif less_than is not None:
        comparison_op = is_less_than
        comparison_val = less_than
        if equal_to is not None:
            comparison_op = is_less_than_or_equal
    elif equal_to is not None:
        comparison_op = is_equal
        comparison_val = equal_to

    # Read through the file records/rows
    line_number = 1
    for line in fin:
        line_stripped = line.strip('\n')
        if line_stripped:
            la = line_stripped.split('\t')
            try:
                val = float(la[column])
                if comparison_op(val, comparison_val):
                    sys.stdout.write(line)
            except ValueError:
                sys.stderr.write('Warning: Non-numeric value in line %i\n%s\n' % (line_number, line))
        line_number += 1

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('file',
                    help='Input file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-k', '--column',
                    help='Column number, with column count starting with 0',
                    type=int,
                    default=0)
    ap.add_argument('-g', '--greater-than',
                    help='select rows containing values > given value',
                    type=float)
    ap.add_argument('-l', '--less-than',
                    help='select rows containing values < given value',
                    type=float)
    ap.add_argument('-e', '--equal-to',
                    help='select rows containing values = given value',
                    type=float)
    params = ap.parse_args()

    # Filter the data
    filter_data(params.file,
                params.column,
                params.greater_than,
                params.less_than,
                params.equal_to)

    params.file.close()
    
if __name__ == '__main__':
    main()
