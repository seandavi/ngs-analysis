#!/bin/bash
## 
## DESCRIPTION:   Generate bamlist for music input with sample, normal.bam, and tumor.bam columns
##                from a file containing a single column list of bam files
##                and a "separator" that separates the sample name from the rest of the filename
##
## USAGE:         music.generate.bamlist.sh bamfileslist [separator]
##
## OUTPUT:        bamlist formatted as specified by WUSTL genome music input
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage_min 1 $# $0

# Process input params
BAMFILESLIST=$1
SEPARATOR=$2
SEPARATOR=${SEPARATOR:='_'}

# Make sure input files exists
assert_file_exists_w_content $BAMFILESLIST

# First, detect normal-tumor pairs
$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/detect_normal_tumor_pairs.py $BAMFILESLIST > $BAMFILESLIST.pairs

# If unable to find the pairs, exit with error
assert_normal_exit_status $? "Unable to find bam pairs"

# Get samples column
for file in `cut -f1 $BAMFILESLIST.pairs`; do
  basename $file | cut -f1 -d $SEPARATOR >> $BAMFILESLIST.pairs.samples
done

# Add samples column
paste $BAMFILESLIST.pairs.samples $BAMFILESLIST.pairs > $BAMFILESLIST.pairs.bamlist
