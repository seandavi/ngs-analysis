#!/bin/bash
##
## DESCRIPTION: Cut adapter sequences from a fastq file
## 
## USAGE: cutadapt.sh input.fastq.gz adaptor_sequence
##
## OUTPUT: input.cutadapt.fastq.gz
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

INPUT_FASTQ=$1
ADAPTOR_SEQ=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $INPUT_FASTQ 2`.cutadapt
OUTPUTFILE=$OUTPUTPREFIX.fastq.gz
OUTPUTSUMMARY=$OUTPUTPREFIX.summary

# Run tool
$CUTADAPT                    \
  -o $OUTPUTFILE             \
  -b $ADAPTOR_SEQ            \
  -e 0.1                     \
  -q 10                      \
  -O 5                       \
  $INPUT_FASTQ               \
  &> $OUTPUTSUMMARY
