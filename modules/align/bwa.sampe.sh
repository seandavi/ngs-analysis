#!/bin/bash
##
## DESCRIPTION:   Convert aligned paired read sai files to a single sam file
##
## USAGE:         bwa.sampe.sh
##                             out_prefix
##                             sample.R1.sai
##                             sample.R2.sai
##                             sample.R1.fastq.gz
##                             sample.R2.fastq.gz
##                             ref.fasta
##
## OUTPUT:        sample.PE.sam.gz
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 6 $# $0

# Process input params
OUTPUTPREFIX=$1
R1_SAI=$2
R2_SAI=$3
R1_FASTQ=$4
R2_FASTQ=$5
REF=$6

# Format output filenames
OUTPUTFILE=$OUTPUTPREFIX.sam.gz
OUTPUTERROR=$OUTPUTPREFIX.sam.gz.err

# Run tool
$BWA                    \
  sampe                 \
  $REF                  \
  $R1_SAI               \
  $R2_SAI               \
  $R1_FASTQ             \
  $R2_FASTQ             \
  | gzip                \
  1> $OUTPUTFILE        \
  2> $OUTPUTERROR
