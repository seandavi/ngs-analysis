#!/bin/bash
##
## DESCRIPTION: Convert aligned single read sai file to sam format
##
## USAGE: bwa.samse.sh sample.RS.aln.sai sample.RS.fastq.gz
##
## OUTPUT: sample.RS.sam.gz
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

RS_SAI=$1
RS_FASTQ=$2

# Format output filenames
OUTPUTPREFIX=`filter_ext $RS_SAI 3`
OUTPUTFILE=$OUTPUTPREFIX.RS.sam.gz
OUTPUTERROR=$OUTPUTPREFIX.RS.sam.err

# Run tool
$BWA                    \
  samse                 \
  $REF                  \
  $RS_SAI               \
  $RS_FASTQ             \
  | gzip                \
  1> $OUTPUTFILE        \
  2> $OUTPUTERROR
