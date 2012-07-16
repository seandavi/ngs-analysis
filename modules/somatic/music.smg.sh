#!/bin/bash
##
## DESCRIPTION:   Run genome muic SMG program which computes P-values and FDRs
##                for each gene
##
## USAGE:         music.smg.sh gene_mr_file
##
## OUTPUT:        gene_mr_file.smg
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

# Process input parameters
MR_FILE=$1
PROCESSORS=20

# Format output filenames
OUTPUTPREFIX=$MR_FILE
OUTPUTFILE=$MR_FILE.smg
OUTPUTLOG=$OUTPUTFILE.log

# Run tool
genome music smg                       \
  --gene-mr-file $MR_FILE              \
  --output-file $OUTPUTFILE            \
  --processors $PROCESSORS             \
  &> $OUTPUTLOG
