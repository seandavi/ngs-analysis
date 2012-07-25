#!/bin/bash
##
## DESCRIPTION:   Align fastq sequences to a reference
##
## USAGE:         bwa.aln.sh foo.fastq.gz out_prefix [thread [seedlen [maxseeddiff]]]
##
## OUTPUT:        out_prefix.sai
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

FASTQ=$1
OUTPREFIX=$2
THREAD=$3
SEEDLEN=$4
MAXSEEDDIFF=$5

# If new values are passed in, then use new values
BWA_ALN_THREAD=${THREAD:=$BWA_ALN_THREAD}
BWA_ALN_SEEDLEN=${SEEDLEN:=$BWA_ALN_SEEDLEN}
BWA_ALN_MAXSEEDDIFF=${MAXSEEDDIFF:=$BWA_ALN_MAXSEEDDIFF}

# Format output filenames
OUTPUTFILE=$OUTPREFIX.sai
OUTPUTERROR=$OUTPREFIX.sai.err

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
