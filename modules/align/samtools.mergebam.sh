#!/bin/bash
## 
## DESCRIPTION: Merge two or more bam files using samtools
##
## USAGE: samtools.mergebam.sh sample.PE.bam sample.SE.bam [...]
##
## OUTPUT: sample.merged.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

INPUTBAM1=$1
OUTPREFIX=`extract_prefix $INPUTBAM1`
OUTPUTBAM=$OUTPREFIX.merged.bam
OUTPUTLOG=$OUTPREFIX.merged.bam.log

$SAMTOOLS          \
  merge            \
  -f               \
    $OUTPUTBAM     \
    $@             \
  &> $OUTPUTLOG
