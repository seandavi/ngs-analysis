#!/usr/bin/env python
description = '''
Validate a bed file, removing rows that are invalid
'''

import argparse
import sys

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('bedfile', 
                    help='Input bed format file',
                    nargs='?', 
                    type=argparse.FileType('r'), 
                    default=sys.stdin)
    params = ap.parse_args()

    with params.bedfile as f:
        for line in f:
            la = line.strip().split()

            # Length test
            if len(la) < 4:
                continue

            # Output
            sys.stdout.write(line)


if __name__ == '__main__':
    main()
