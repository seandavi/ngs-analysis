#!/bin/bash
##
## DESCRIPTION:   Trim off low quality regions of fastq sequences
##
## USAGE:         sickle.pe.sh sample.R1.fastq.gz sample.R2.fastq.gz
##
## OUTPUT:        sample.R1.trimmed.fastq sample.R2.trimmed.fastq sample.SE.trimmed.fastq
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

FASTQ_READ1=$1
FASTQ_READ2=$2

# Format output filenames
OUTPUTPREFIX_R1=`filter_ext $FASTQ_READ1 2`
OUTPUT_R1=`filter_ext $FASTQ_READ1 2`.trimmed.fastq
OUTPUT_R2=`filter_ext $FASTQ_READ2 2`.trimmed.fastq
OUTPUT_SE=`filter_ext $FASTQ_READ1 2 | sed 's/R1/SE/'`.trimmed.fastq
OUTPUTLOG=`filter_ext $FASTQ_READ1 2 | sed 's/R1/SE/'`.trimmed.log

# Run tool
$SICKLE                   \
  pe                      \
  -t sanger               \
  -f $FASTQ_READ1         \
  -r $FASTQ_READ2         \
  -q $QUAL_THRESH         \
  -l $READLENGTH_MIN      \
  -o $OUTPUT_R1           \
  -p $OUTPUT_R2           \
  -s $OUTPUT_SE           \
  &> $OUTPUTLOG
