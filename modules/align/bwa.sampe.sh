#!/bin/bash
##
## DESCRIPTION:   Convert aligned paired read sai files to a single sam file
##
## USAGE:         bwa.sampe.sh sample.R1.sai sample.R2.sai sample.R1.fastq.gz sample.R2.fastq.gz ref.fasta
##
## OUTPUT:        sample.PE.sam.gz
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 5 $# $0

R1_SAI=$1
R2_SAI=$2
R1_FASTQ=$3
R2_FASTQ=$4
REF=$5

# Format output filenames
OUTPUTPREFIX=`filter_ext $R1_SAI 1 | sed 's/R1/PE/'`
OUTPUTFILE=$OUTPUTPREFIX.sam.gz
OUTPUTERROR=$OUTPUTPREFIX.sam.err

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
