#!/bin/bash
## 
## DESCRIPTION:   List all files within a directory that ends with the given suffix
##
## USAGE:         listfiles.suffix.sh dirname suffix outfile
##
## OUTPUT:        outfile
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage_min 2 $# $0

DIRNAME=$1
SUFFIX=$2
OUTFILE=$3

find $DIRNAME -name "*$SUFFIX" > $OUTFILE
