#!/bin/bash
##
## DESCRIPTION: Align fastq sequences to a reference
##
## USAGE: bwa.aln.sh foo.fastq.gz
##
## OUTPUT: foo.aln.sai
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

FASTQ=$1

# Format output filenames
OUTPUTPREFIX=`filter_ext $FASTQ 2`
OUTPUTFILE=$OUTPUTPREFIX.aln.sai
OUTPUTERROR=$OUTPUTPREFIX.aln.err

# Run tool
$BWA                  \
  aln                 \
  -t 2                \
  -l 32               \
  -k 2                \
  $REF                \
  $FASTQ              \
  1> $OUTPUTFILE      \
  2> $OUTPUTERROR
