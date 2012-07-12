#!/bin/bash
## 
## DESCRIPTION:   Intersect two bed files, output entries in a.bed
##                that had no overlaps with b.bed
##
## USAGE:         bedtools.intersect.v.sh a.bed b.bed output.bed
##
## OUTPUT:        output.bed
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 3 $# $0

LEFTFILE=$1
RIGHTFILE=$2
OUTPUTFILE=$3

$BEDTOOLS_PATH/intersectBed     \
  -a $LEFTFILE                  \
  -b $RIGHTFILE                 \
  -v                            \
  > $OUTPUTFILE