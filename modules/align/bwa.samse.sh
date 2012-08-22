#!/bin/bash
##
## DESCRIPTION:   Convert aligned single read sai file to sam format
##
## USAGE:         bwa.samse.sh
##                             output_prefix
##                             sample.SE.sai
##                             sample.SE.fastq.gz
##                             ref.fasta
##
## OUTPUT:        sample.SE.sam.gz
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 4 $# $0

OUTPUTPREFIX=$1
SE_SAI=$2
SE_FASTQ=$3
REF=$4

# Format output filenames
OUTPUTFILE=$OUTPUTPREFIX.sam.gz
OUTPUTERROR=$OUTPUTPREFIX.sam.gz.err

# Run tool
$BWA                    \
  samse                 \
  $REF                  \
  $SE_SAI               \
  $SE_FASTQ             \
  | gzip                \
  1> $OUTPUTFILE        \
  2> $OUTPUTERROR
