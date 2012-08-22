#!/bin/bash
## 
## DESCRIPTION:   Merge two or more bam files using samtools
##
## USAGE:         samtools.mergebam.sh
##                                     out_prefix
##                                     sample.PE.bam
##                                     sample.SE.bam
##                                     [...]
##
## OUTPUT:        out_prefix.bam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process parameters
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
OUTPREFIX=${PARAMS[0]}
NUM_BAMFILES=$(($NUM_PARAMS - 1))
BAMFILES=${PARAMS[@]:1:$NUM_BAMFILES}
OUTPUTBAM=$OUTPREFIX.bam
OUTPUTLOG=$OUTPREFIX.bam.log

# If the input only contains a single bamfile,
# create symbolic link to out_prefix.bam
if [ $NUM_BAMFILES -eq 1 ]; then
  SINGLE_BAMFILE=${PARAMS[1]}
  ln -s $SINGLE_BAMFILE $OUTPUTBAM
  exit
fi

# Merge multiple bam files
$SAMTOOLS          \
  merge            \
  -f               \
    $OUTPUTBAM     \
    $BAMFILES      \
  &> $OUTPUTLOG
