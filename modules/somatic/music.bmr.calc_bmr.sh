#!/bin/bash
##
## DESCRIPTION:   Calulate background mutation rate
##
## USAGE:         music.bmr.calc_bmr.sh bamlist maf_file roi_bed_file [ref.fa]
##
## OUTPUT:        sample.bam.mpileup
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input parameters
BAMLIST=$1
MAFFILE=$2
ROI_BED=$3
REFEREN=$4
REFEREN=${REFEREN:=$REF}

# Format output filenames
OUTPUTPREFIX=$BAMLIST.music.calc-bmr
OUTPUTDIR=$BAMLIST.music
OUTPUTLOG=$OUTPUTPREFIX.log

# Run tool
genome music bmr calc-bmr              \
  --roi-file=$ROI_BED                  \
  --reference-sequence=$REFEREN        \
  --bam-list=$BAMLIST                  \
  --output-dir=$OUTPUTDIR              \
  --maf-file=$MAFFILE                  \
  --skip-non-coding                    \
  --skip-silent                        \
  &> $OUTPUTLOG
