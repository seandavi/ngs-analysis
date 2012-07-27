#!/bin/bash
##
## DESCRIPTION:   Find clustered mutations in close proximity
##
## USAGE:         music.proximity.sh maf_file output_dir [max_proximity]
##
## OUTPUT:        output_dir/proximity.tsv
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
MAFFILE=$1
OUT_DIR=$2
PROXIMI=$3

# Set optional parameters
if [ -z $PROXIMI ]; then
  OPTION_PROXIMITY=''
else
  OPTION_PROXIMITY='--max-proximity='$PROXIMI
fi

# Format output filenames
OUTPUTLOG=$OUT_DIR.proximity.log

# Run tool
genome music proximity                    \
  --maf-file $MAFFILE                     \
  --output-dir $OUT_DIR                   \
  $OPTION_PROXIMITY                       \
  &> $OUTPUTLOG
