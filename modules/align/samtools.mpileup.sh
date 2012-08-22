#!/bin/bash
##
## DESCRIPTION:   Generate mpileups of bam files
##
## USAGE:         samtools.mpileup.sh sample.bam ref.fasta ["other_mpileup_options"] 
##
## OUTPUT:        sample.bam.mpileup
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input params
BAMFILE=$1
REF=$2
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUM_OPTIONS=$(($NUM_PARAMS - 2))
OPTIONS=${PARAMS[@]:2:$NUM_OPTIONS}

# Format output filenames
OUTPUTPREFIX=$BAMFILE
OUTPUTFILE=$OUTPUTPREFIX.mpileup
OUTPUTERROR=$OUTPUTFILE.err

# If mpileup exists, and has content, don't run
assert_file_not_exists_w_content $OUTPUTFILE

# Run tool
$SAMTOOLS             \
  mpileup             \
  $OPTIONS            \
  -f $REF      	      \
  $BAMFILE            \
  1> $OUTPUTFILE      \
  2> $OUTPUTERROR
