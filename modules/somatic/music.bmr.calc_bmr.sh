#!/bin/bash
##
## DESCRIPTION:   Calulate background mutation rate
##
## USAGE:         music.bmr.calc_bmr.sh
##                                      bamlist
##                                      maf_file
##                                      roi_bed_file
##                                      out_dir
##                                      ref.fa
##                                      [dont_skip_silent_noncoding]
##
## OUTPUT:        bamlist.music/
##                  gene_mrs
##                  overall_bmrs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 5 $# $0

# Process input parameters
BAMLIST=$1
MAFFILE=$2
ROI_BED=$3
OUT_DIR=$4
REFEREN=$5
NOSKIP=$6

if [ ! -z "$NOSKIP" ]; then
  NOSKIP_PARAMS='--noskip-silent --noskip-non-coding'
fi

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
  --show-skipped                       \
  $NOSKIP_PARAMS                       \
  &> $OUTPUTLOG
