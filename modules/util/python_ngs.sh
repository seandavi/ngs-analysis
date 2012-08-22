#!/bin/bash
## 
## DESCRIPTION:   Python wrapper to call ngs-analysis python scripts without having to give the full path,
##                since when calling locally installed python, the user must give the full path to the
##                python script.
##
## USAGE:         python_ngs.sh foo.py -a A -b B [...]
##
## OUTPUT:        foo.py's output
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage_min 1 $# $0

# Process input params
TOOL=$1
TOOL_DIR=$(dirname `which $TOOL`)

$PYTHON $TOOL_DIR/$@
