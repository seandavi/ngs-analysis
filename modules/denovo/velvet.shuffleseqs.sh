#!/bin/bash
## 
## DESCRIPTION:   Prepare to run velvet by merging paired fastq files
##
## USAGE:         velvet.shuffleseqs.sh
##                                      sample.R1.fastq
##                                      sample.R2.fastq
##                                      outfile
##
## OUTPUT:        outfile
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 3 $# $0

# Process input params
FASTQ_R1=$1
FASTQ_R2=$2
OUT_FILE=$3

shuffleSequences_fastq.pl   \
  $FASTQ_R1                 \
  $FASTQ_R2                 \
  $OUT_FILE                 \
  &> $OUT_FILE.log
