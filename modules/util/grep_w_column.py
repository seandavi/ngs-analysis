#!/usr/bin/env python
description = '''
Tool similar to grep -w option for extracting exact word matches from a specific column.
Implemented because grep -w was so slow
'''

import argparse
import sys


def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('search_keys', 
                    help='Columnar list of search terms', 
                    nargs='?', 
                    type=argparse.FileType('r'), 
                    default=sys.stdin)
    ap.add_argument('data_file',
                    help='File to search for terms',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    ap.add_argument('-k', '--column', 
                    help='Column number to search the key terms for in the data file, with column count starting with 0', 
                    type=int, 
                    default=0)
    ap.add_argument('-i', '--ignore-case', 
                    help='Ignore case when matching',
                    action='store_true')
    params = ap.parse_args()

    # Load search key list to memory
    search_words = set()
    for line in params.search_keys:
        sw = line.strip().split('\t')[0]
        if params.ignore_case:
            sw = sw.lower()
        search_words.add(sw)
    params.search_keys.close()

    # Close file input stream
    for line in params.data_file:
        target_word = line.strip('\n').split('\t')[params.column]
        if params.ignore_case:
            target_word = target_word.lower()
        if target_word in search_words:
            sys.stdout.write(line)
        
    params.data_file.close()
    

if __name__ == '__main__':
    main()
