#!/bin/bash
##
## DESCRIPTION:   Calulate background mutation rate
##
## USAGE:         music.bmr.calc_bmr.sh bamlist maf_file roi_bed_file out_dir [ref.fa]
##
## OUTPUT:        bamlist.music/
##                  gene_mrs
##                  overall_bmrs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 4 $# $0

# Process input parameters
BAMLIST=$1
MAFFILE=$2
ROI_BED=$3
OUT_DIR=$4
REFEREN=$5
REFEREN=${REFEREN:=$REF}

# Format output filenames
OUTPUTPREFIX=$OUT_DIR.calc-bmr
OUTPUTLOG=$OUTPUTPREFIX.log

# Run tool
genome music bmr calc-bmr              \
  --roi-file=$ROI_BED                  \
  --reference-sequence=$REFEREN        \
  --bam-list=$BAMLIST                  \
  --output-dir=$OUT_DIR                \
  --maf-file=$MAFFILE                  \
  --skip-non-coding                    \
  --skip-silent                        \
  &> $OUTPUTLOG
