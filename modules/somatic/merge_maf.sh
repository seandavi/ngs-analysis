#!/bin/bash
## 
## DESCRIPTION:   Merge maf files
##
## USAGE:         merge_maf.sh out_prefix sample1.maf sample2.maf [...]
##
## OUTPUT:        out_prefix.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage_min 3 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
OUT_PREFIX=${PARAMS[0]}
NUM_MAFS=$(($NUM_PARAMS - 1))
IN_MAFS=${PARAMS[@]:1:$NUM_MAFS}

# Format output
OUTMAF=$OUT_PREFIX.maf
TMPFILE=$OUT_PREFIX.maf.tmp

# Merge maf files
cat $NGS_ANALYSIS_DIR/resources/tcga.maf.header > $OUTMAF
for i in $IN_MAFS; do 
  cat $OUTMAF <(sed 1d $i) > $TMPFILE
  mv $TMPFILE $OUTMAF
done
