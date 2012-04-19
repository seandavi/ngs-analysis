#!/bin/bash
##
## DESCRIPTION: Align fastq sequences to a reference
##
## USAGE: bwa.aln.sh foo.fastq.gz
##
## OUTPUT: foo.aln.sai
##

# Load bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Check correct usage
usage 1 $# $0

# Format output filenames
OUTPUTPREFIX=`filter_ext $1 2`
OUTPUTFILE=$OUTPUTPREFIX.aln.sai
OUTPUTERROR=$OUTPUTPREFIX.aln.err

# Run tool
$BWA                  \
  aln                 \
  -t 2                \
  -l 32               \
  -k 2                \
  $REF                \
  $1                  \
  1> $OUTPUTFILE      \
  2> $OUTPUTERROR
