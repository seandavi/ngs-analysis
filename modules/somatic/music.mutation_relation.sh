#!/bin/bash
##
## DESCRIPTION:   Find correlations between genes among samples.
##                Positive correlation may imply cooperative function.
##                Negative correlation may imply mutual exclusivity, due to
##                alternate disease pathways.
##
## USAGE:         music.mutation_relation.sh bamlist maf_file output_dir [permutations [gene_list]]
##
## OUTPUT:        output_dir/mutation_relation.tsv
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input parameters
BAMLIST=$1
MAFFILE=$2
OUT_DIR=$3
PERMUTS=$4
GENELST=$5

# Set optional parameters
if [ -z $GENELST ]; then
  OPTION_GENE_LIST=''
else
  OPTION_GENE_LIST='--gene-list='$GENELST
fi
if [ -z $PERMUTS ]; then
  OPTION_PERMUTATIONS=''
else
  OPTION_PERMUTATIONS='--permutations='$PERMUTS
fi

# Format output filenames
OUTPUTFILE=$OUT_DIR/mutation_relation.tsv
OUTPUTLOG=$OUT_DIR.mutation_relation.log

# Run tool
genome music mutation-relation            \
  --bam-list=$BAMLIST                     \
  --maf-file=$MAFFILE                     \
  --output-file=$OUTPUTFILE               \
  $OPTION_PERMUTATIONS                    \
  $OPTION_GENE_LIST                       \
  &> $OUTPUTLOG
