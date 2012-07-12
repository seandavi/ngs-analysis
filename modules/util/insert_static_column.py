#!/usr/bin/env python
description = '''
Given a file containing columnar data, insert a static value column into the data
'''

import argparse
import sys

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('input_file',
                    help='Input data file',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('value',
                    help='Static value to input into the file as a column',
                    type=str)
    ap.add_argument('-k', '--column',
                    help='Column to insert the value into',
                    type=int,
                    default=0)
    params = ap.parse_args()
    
    for line in params.input_file:
        la = line.strip().split('\t')
        la.insert(params.column, params.value)
        sys.stdout.write('%s\n' % '\t'.join(la))
    params.input_file.close()
        
if __name__ == '__main__':
    main()
            
            
