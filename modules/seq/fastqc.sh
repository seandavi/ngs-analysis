#!/bin/bash
##
## DESCRIPTION:   Run FastQC
## 
## USAGE:         fastqc.sh input.fastq.gz [num_threads]
##
## OUTPUT:        FastQC output folder containing fastq qc info
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

INPUT_FASTQ=$1
NUM_THREADS=$2
NUM_THREADS=${NUM_THREADS:=2}

# Format output filenames
OUTPUTPREFIX=$INPUT_FASTQ
OUTPUTLOG=$OUTPUTPREFIX.log

# Run tool
$FASTQC                      \
  -t $NUM_THREADS            \
  $INPUT_FASTQ               \
  &> $OUTPUTLOG
