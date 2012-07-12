#!/bin/bash
## 
## DESCRIPTION:   Convert bed that had been converted from tcga maf format file
##                back to maf format after being intersected with sureselect bed
##
## USAGE:         mafbed_sureselect2maf.sh input.bed
##
## OUTPUT:        input.bed.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage 1 $# $0

BEDFILE=$1

# Format output
OUTPUTPREFIX=$BEDFILE
OUTPUTFILE=$OUTPUTPREFIX.maf


paste                                                                            \
  <(cut -f8 $BEDFILE)                                                            \
  <(cut -f1-4 $BEDFILE | sed 's/:/\t/g' | cut -f 30-32)                          \
  <(cut -f1-4 $BEDFILE | sed 's/:/\t/g' | cut -f 1-28                            \
      | $PYTHON $NGS_ANALYSIS_DIR/modules/util/data_numeric_modify_column.py     \
          -k 1                                                                   \
          -t add                                                                 \
          -v 1)                                                                  \
  | cat $NGS_ANALYSIS_DIR/resources/tcga.maf.header -                            \
  > $OUTPUTFILE
