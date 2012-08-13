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

BAMFILE=$1
REF=$2
OPTIONS=$3

# Format output filenames
OUTPUTPREFIX=$BAMFILE
OUTPUTFILE=$OUTPUTPREFIX.mpileup
OUTPUTERROR=$OUTPUTFILE.err

# Run tool
$SAMTOOLS             \
  mpileup             \
  $OPTIONS            \
  -f $REF      	      \
  $BAMFILE            \
  1> $OUTPUTFILE      \
  2> $OUTPUTERROR
