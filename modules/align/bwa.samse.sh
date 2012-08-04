#!/bin/bash
##
## DESCRIPTION:   Convert aligned single read sai file to sam format
##
## USAGE:         bwa.samse.sh sample.SE.sai sample.SE.fastq.gz ref.fasta
##
## OUTPUT:        sample.SE.sam.gz
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 3 $# $0

SE_SAI=$1
SE_FASTQ=$2
REF=$3

# Format output filenames
OUTPUTPREFIX=`filter_ext $SE_SAI 1`
OUTPUTFILE=$OUTPUTPREFIX.sam.gz
OUTPUTERROR=$OUTPUTPREFIX.sam.err

# Run tool
$BWA                    \
  samse                 \
  $REF                  \
  $SE_SAI               \
  $SE_FASTQ             \
  | gzip                \
  1> $OUTPUTFILE        \
  2> $OUTPUTERROR
