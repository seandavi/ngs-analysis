#!/bin/bash
##
## DESCRIPTION:   Count covered bases for normal/tumor pair of bam files
##
## USAGE:         music.bmr.calc_covg.sh bamlist roi_bed_file [ref.fa]
##
## OUTPUT:        bamlist.music/
##                  gene_covgs
##                  roi_covgs
##                  total_covgs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
BAMLIST=$1
ROI_BED=$2
REFEREN=$3
REFEREN=${REFEREN:=$REF}

# Format output filenames
OUTPUTPREFIX=$BAMLIST.music.calc-covg
OUTPUTDIR=$BAMLIST.music
OUTPUTLOG=$OUTPUTPREFIX.log

# Run tool
genome music bmr calc-covg             \
  --roi-file=$ROI_BED                  \
  --reference-sequence=$REFEREN        \
  --bam-list=$BAMLIST                  \
  --output-dir=$OUTPUTDIR              \
  &> $OUTPUTLOG

# Run again to generate total_covgs
genome music bmr calc-covg             \
  --roi-file=$ROI_BED                  \
  --reference-sequence=$REFEREN        \
  --bam-list=$BAMLIST                  \
  --output-dir=$OUTPUTDIR              \
  &> $OUTPUTLOG.2
