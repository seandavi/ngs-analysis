#!/bin/bash
##
## DESCRIPTION:   Run genome muic SMG program which computes P-values and FDRs
##                for each gene
##
## USAGE:         music.smg.sh gene_mrs output_dir [num_parallel]
##
## OUTPUT:        gene_mr_file.smg
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input parameters
MR_FILE=$1
OUT_DIR=$2
PROCESSORS=$3
PROCESSORS=${PROCESSORS:=20}

# Format output filenames
OUTPUTFILE=$OUT_DIR/smg
OUTPUTLOG=$OUT_DIR.smg.log

# Run tool
genome music smg                       \
  --gene-mr-file $MR_FILE              \
  --output-file $OUTPUTFILE            \
  --processors $PROCESSORS             \
  &> $OUTPUTLOG
