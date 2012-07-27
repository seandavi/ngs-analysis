#!/bin/bash
##
## DESCRIPTION:   Add pfam annotations to a maf file
##
## USAGE:         music.pfam.sh maf_file output_dir
##
## OUTPUT:        output_dir/pfam
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 2 $# $0

# Process input parameters
MAFFILE=$1
OUT_DIR=$2

# Format output filenames
OUTPUTFILE=$OUT_DIR/pfam
OUTPUTLOG=$OUT_DIR.pfam.log

# Run tool
genome music pfam                         \
  --maf-file=$MAFFILE                     \
  --output-file=$OUTPUTFILE               \
  --reference-build=Build37               \
  &> $OUTPUTLOG
