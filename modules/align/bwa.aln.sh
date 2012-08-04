#!/bin/bash
##
## DESCRIPTION:   Align fastq sequences to a reference
##
## USAGE:         bwa.aln.sh foo.fastq.gz out_prefix ref.fasta [thread [seedlen [maxseeddiff]]]
##
## OUTPUT:        out_prefix.sai
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

FASTQ=$1
OUTPREFIX=$2
REF=$3
THREAD=$4
SEEDLEN=$5
MAXSEEDDIFF=$6

# If new values are passed in, then use new values
THREAD=${THREAD:=2}
SEEDLEN=${SEEDLEN:=32}
MAXSEEDDIFF=${MAXSEEDDIFF:=2}

# Format output filenames
OUTPUTFILE=$OUTPREFIX.sai
OUTPUTERROR=$OUTPREFIX.sai.err

# Run tool
$BWA                         \
  aln                        \
  -t $THREAD                 \
  -l $SEEDLEN                \
  -k $MAXSEEDDIFF            \
  $REF                       \
  $FASTQ                     \
  1> $OUTPUTFILE             \
  2> $OUTPUTERROR
