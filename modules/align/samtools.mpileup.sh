#!/bin/bash
##
## DESCRIPTION:   Generate mpileups of bam files
##
## USAGE:         samtools.mpileup.sh sample.bam ["other_mpileup_options"] 
##
## OUTPUT:        sample.bam.mpileup
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

BAMFILE=$1
OPTIONS=$2

# Format output filenames
OUTPUTPREFIX=$BAMFILE
OUTPUTFILE=$OUTPUTPREFIX.mpileup
OUTPUTERROR=$OUTPUTFILE.err

# Run tool
$SAMTOOLS             \
  mpileup             \
  -f $REF      	      \
  $OPTIONS            \
  $BAMFILE            \
  1> $OUTPUTFILE      \
  2> $OUTPUTERROR
