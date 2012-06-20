#!/bin/bash
## 
## DESCRIPTION: Merge two or more bam files using samtools
##
## USAGE: samtools.mergebam.sh sample.RP.bam sample.RS.bam [...]
##
## OUTPUT: sample.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

INPUTBAM1=$1
OUTPREFIX=`extract_prefix $INPUTBAM1`
OUTPUTBAM=$OUTPREFIX.bam

$SAMTOOLS          \
  merge            \
  -f               \
    $OUTPUTBAM     \
    $@
