#!/bin/bash
##
## DESCRIPTION: Trim off low quality regions of fastq sequences
##
## USAGE: sickle.pe.sh sample.R1.fastq.gz sample.R2.fastq.gz
##
## OUTPUT: sample.R1.sickle.fastq.gz sample.R2.sickle.fastq.gz sample.RS.sickle.fastq.gz
##

# Load analysis config
source $NGS_ANALYSIS_DIR/ngs.config.sh

# Check correct usage
usage 2 $# $0

FASTQ_READ1=$1
FASTQ_READ2=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $FASTQ_READ1 3`
OUTPUT_R1=$OUTPUTPREFIX.R1.trimmed.fastq.gz
OUTPUT_R2=$OUTPUTPREFIX.R2.trimmed.fastq.gz
OUTPUT_RS=$OUTPUTPREFIX.RS.trimmed.fastq.gz
OUTPUTSUMMARY=$OUTPUTPREFIX.RX.trimmed.summary

# Run tool
$SICKLE                   \
  pe                      \
  -t sanger               \
  -f $FASTQ_READ1         \
  -r $FASTQ_READ2         \
  -q 20                   \
  -l $READLENGTH_MIN      \
  -o $OUTPUT_R1           \
  -p $OUTPUT_R2           \
  -s $OUTPUT_RS           \
  &> $OUTPUTSUMMARY
