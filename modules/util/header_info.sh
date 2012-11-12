#!/bin/bash
## 
## DESCRIPTION:   Given column data, take the first 'num_lines' rows and transpose it, and output with column numbers
##
## USAGE:         header_info.sh
##                               data_file
##                               [num_lines (default 2)]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 1 $# $0

# Process parameters
FILE_N=$1
NLINES=$2

# Make sure file exists
assert_file_exists_w_content $FILE_N

# Set default number of rows
if [ -z $NLINES ]; then
  NLINES=2
fi

head -n $NLINES $FILE_N | $PYTHON -c "import sys, itertools, string;                                                 \
print '\n'.join(('%s\t%s' % (string.rjust(str(i+1),3),                                                               \
                             '\t'.join(map(string.rjust,                                                             \
                                           row,                                                                      \
                                           [len(max(line.strip('\n').split('\t'), key=len))+2 for i in range(len(row))])))   \
                             for i,row in enumerate(itertools.izip(*[line.strip('\n').split('\t') for line in sys.stdin]))))"
