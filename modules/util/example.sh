#!/bin/bash
## 
## DESCRIPTION: Example script template
##
## USAGE: example.sh foo
##
## OUTPUT: None
##

# Include library of bash functions
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Usage check:
# 1st parameter is the desired number of parameters: 1 in this case, i.e. foo
# Second parameter is the actual number of parameters passed in
# Third parameter is the path to this script
usage 1 $# $0

echo 'hello world!'