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
PARAMS=($@)
TOOL=${PARAMS[0]}
TOOL_PARAMS=${@:2}
TOOL_DIR=$(dirname `which $TOOL`)
TOOL_NAME=$(basename $TOOL)

# Run the tool
$PYTHON $TOOL_DIR/$TOOL_NAME $TOOL_PARAMS
