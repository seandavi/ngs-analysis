#!/bin/bash
##
## DESCRIPTION:   Trim off low quality regions of fastq sequences
##
## USAGE:         sickle.pe.sh R1.fastq.gz R2.fastq.gz [min_readlength [qual_thresh]]
##
## OUTPUT:        R1.fastq.gz.trimmed.fastq
##                R2.fastq.gz.trimmed.fastq
##                SE.fastq.gz.trimmed.fastq
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

FASTQ_READ1=$1
FASTQ_READ2=$2
MIN_READLEN=$3
QUAL_THRESH=$4
MIN_READLEN=${MIN_READLEN:=20}
QUAL_THRESH=${QUAL_THRESH:=20}

# Format output filenames
OUTPUT_R1=$FASTQ_READ1.trimmed.fastq
OUTPUT_R2=$FASTQ_READ2.trimmed.fastq
OUTPUT_SE=`echo $OUTPUT_R1 | sed 's/R1/SE/'`
OUTPUTLOG=$OUTPUT_SE.log

# Run tool
$SICKLE                   \
  pe                      \
  -t sanger               \
  -f $FASTQ_READ1         \
  -r $FASTQ_READ2         \
  -q $QUAL_THRESH         \
  -l $MIN_READLEN         \
  -o $OUTPUT_R1           \
  -p $OUTPUT_R2           \
  -s $OUTPUT_SE           \
  &> $OUTPUTLOG
