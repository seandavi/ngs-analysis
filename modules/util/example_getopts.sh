#!/bin/bash
## 
## DESCRIPTION:   Example script template
##
## USAGE:         example_getopts.sh -a option_a -b -c option_c x1 x2 x3
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
# 1st parameter is the desired number of parameters: 1 in this case, i.e. foo
# Second parameter is the actual number of parameters passed in
# Third parameter is the path to this script
usage_min 1 $# $0

echo $#

while getopts ":ha:b:c" opt; do
  case $opt in
    a) echo $OPTARG;;
    b) echo $OPTARG;;
    c) echo 'hello';;
    h) sed -n '/^##/,/^$/s/^## \{0,1\}//p' $0
        exit 2;;
    \?) usage;;
  esac
done


echo 'hello world!'