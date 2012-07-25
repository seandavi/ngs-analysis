#!/bin/bash
## 
## DESCRIPTION:   Merge two or more bam files using samtools
##
## USAGE:         samtools.mergebam.sh out_prefix sample.PE.bam sample.SE.bam [...]
##
## OUTPUT:        out_prefix.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process parameters
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
OUTPREFIX=${PARAMS[0]}
NUM_BAMFILES=$(($NUM_PARAMS - 1))
BAMFILES=${PARAMS[@]:1:$NUM_BAMFILES}
OUTPUTBAM=$OUTPREFIX.bam
OUTPUTLOG=$OUTPREFIX.bam.log

# Run tool
$SAMTOOLS          \
  merge            \
  -f               \
    $OUTPUTBAM     \
    $BAMFILES      \
  &> $OUTPUTLOG
