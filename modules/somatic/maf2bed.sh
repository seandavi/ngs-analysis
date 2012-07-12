#!/bin/bash
## 
## DESCRIPTION:   Convert tcga maf format file to bed format
##
## USAGE:         maf2bed.sh input.maf
##
## OUTPUT:        input.maf.bed
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage 1 $# $0

MAFFILE=$1

# Format output
OUTPUTPREFIX=$MAFFILE
OUTPUTFILE=$OUTPUTPREFIX.bed

paste                                                                            \
  <(cut -f5- $MAFFILE)                                                           \
  <(cut -f1-4 $MAFFILE)                                                          \
  | sed 1d                                                                       \
  | $PYTHON $NGS_ANALYSIS_DIR/modules/util/data_numeric_modify_column.py         \
      -k 1                                                                       \
      -t add                                                                     \
      -v -1                                                                      \
  | python -c "exec(\"import sys\nfor line in sys.stdin: la = line.strip().split('\t'); print '\t'.join(la[:3]) + '\t' +  ':'.join(la[3:])\")" \
  > $OUTPUTFILE
