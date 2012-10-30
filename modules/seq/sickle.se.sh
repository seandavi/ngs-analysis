#!/bin/bash
##
## DESCRIPTION:   Trim off low quality regions of SE fastq sequences
##
## USAGE:         sickle.se.sh R1.fastq.gz [min_readlength [qual_thresh]]
##
## OUTPUT:        R1.fastq.gz.trim.fastq
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

FASTQ_READ1=$1
MIN_READLEN=$2
QUAL_THRESH=$3
MIN_READLEN=${MIN_READLEN:=20}
QUAL_THRESH=${QUAL_THRESH:=20}

# Format output filenames
OUTPUT_R1=$FASTQ_READ1.trim.fastq
OUTPUTLOG=$OUTPUT_R1.log

# Run tool
$SICKLE                   \
  se                      \
  -t sanger               \
  -f $FASTQ_READ1         \
  -q $QUAL_THRESH         \
  -l $MIN_READLEN         \
  -o $OUTPUT_R1           \
  &> $OUTPUTLOG
