#!/bin/bash
## 
## DESCRIPTION:   Merge maf files
##
## USAGE:         merge_maf.sh sample1.maf sample2.maf [...]
##
## OUTPUT:        samples.maf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check
usage_min 1 $# $0

OUTMAF=samples.maf
TMPFILE=samples.maf.tmp

cat $NGS_ANALYSIS_DIR/resources/tcga.maf.header > $OUTMAF
for i in $@; do 
  cat $OUTMAF <(sed 1d $i) > $TMPFILE
  mv $TMPFILE $OUTMAF
done
