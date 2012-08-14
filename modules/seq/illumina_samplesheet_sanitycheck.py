#!/usr/bin/env python
description = '''
Sanity check Illumina Hiseq/GA samplesheets
Run sanity check on the samplesheet
- Number of columns in each row must be the same
- Cannot have spaces, forward or backward slashes (illegal chars)
- Length of index sequences must all be the same
- Cannot have same index for same lane
- Character set - no weird symbols
'''

import argparse
import sys
from ngs import samplesheet

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('samplesheet', 
                    help='Input samplesheet csv file', 
                    nargs='?', 
                    type=argparse.FileType('r'), 
                    default=sys.stdin)
    params = ap.parse_args()

    # Read samplesheet string to memory
    samplesheet_str = params.samplesheet.read()
    # Close file input stream
    params.samplesheet.close()

    # Run sanity check
    valid = samplesheet.SampleSheet(samplesheet_str).check_sanity()
    
    if not valid:
        sys.exit(1)

    
if __name__ == '__main__':
    main()
