#!/bin/bash
##
## DESCRIPTION: Align fastq sequences to a reference
##
## USAGE: bwa.aln.sh foo.fastq.gz [thread [seedlen [maxseeddiff]]]
##
## OUTPUT: foo.aln.sai
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

FASTQ=$1
THREAD=$2
SEEDLEN=$3
MAXSEEDDIFF=$4

# If new values are passed in, then use new values
BWA_ALN_THREAD=${THREAD:=$BWA_ALN_THREAD}
BWA_ALN_SEEDLEN=${SEEDLEN:=$BWA_ALN_SEEDLEN}
BWA_ALN_MAXSEEDDIFF=${MAXSEEDDIFF:=$BWA_ALN_MAXSEEDDIFF}

# Format output filenames
OUTPUTPREFIX=`filter_ext $FASTQ 2`
OUTPUTFILE=$OUTPUTPREFIX.aln.sai
OUTPUTERROR=$OUTPUTPREFIX.aln.err

# Run tool
$BWA                         \
  aln                        \
  -t $BWA_ALN_THREAD         \
  -l $BWA_ALN_SEEDLEN        \
  -k $BWA_ALN_MAXSEEDDIFF    \
  $REF                       \
  $FASTQ                     \
  1> $OUTPUTFILE             \
  2> $OUTPUTERROR
