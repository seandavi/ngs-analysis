#!/bin/bash
## 
## DESCRIPTION:   Generate stats table from the Log files of velvet output folders
##
## USAGE:         velvet.stats.sh
##                                output_dirs
##
## OUTPUT:        
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 1 $# $0

# Process input params
OUTDIRS=$@

LOGFILES=''
for dirname in $OUTDIRS; do
  LOGFILES=$LOGFILES' '$dirname/Log
done

# Generate stats
COLHEAD=`paste <(cat $LOGFILES | grep Final | cut -f5,7,10,12 -d ' ' | sort -u) <(echo -e "used_reads\ttotal_reads")`
cat <(echo $COLHEAD) <(cat $LOGFILES | grep Final | cut -f4,9,11,13,15 -d' ' | sed 's/,//g' | sed 's/\// /' | sed 's/ /\t/g') | sed 's/ /\t/g'
