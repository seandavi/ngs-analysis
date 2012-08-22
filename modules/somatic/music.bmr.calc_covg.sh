#!/bin/bash
##
## DESCRIPTION:   Count covered bases for normal/tumor pair of bam files
##
## USAGE:         music.bmr.calc_covg.sh bamlist roi_bed_file out_dir ref.fa
##
## OUTPUT:        bamlist.music/
##                  gene_covgs
##                  roi_covgs
##                  total_covgs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 4 $# $0

# Process input parameters
BAMLIST=$1
ROI_BED=$2
OUT_DIR=$3
REFEREN=$4

# Format output filenames
OUTPUTPREFIX=$OUT_DIR.calc-covg
OUTPUTLOG=$OUTPUTPREFIX.log
OUTPUTLOG2=$OUTPUTPREFIX.2.log

# Create output directory
if [ -d "$OUT_DIR" ]; then
  echoerr "Output directory already exists."
  exit 1
fi
mkdir $OUT_DIR

# Run tool
genome music bmr calc-covg             \
  --roi-file $ROI_BED                  \
  --reference-sequence $REFEREN        \
  --bam-list $BAMLIST                  \
  --output-dir $OUT_DIR                \
  &> $OUTPUTLOG

# Check if tool ran successfully
if [ $? -ne 0 ]; then
  exit 1
fi

# Run again to generate total_covgs
genome music bmr calc-covg             \
  --roi-file $ROI_BED                  \
  --reference-sequence $REFEREN        \
  --bam-list $BAMLIST                  \
  --output-dir $OUT_DIR                \
  &> $OUTPUTLOG2
