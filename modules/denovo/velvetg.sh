#!/bin/bash
## 
## DESCRIPTION:   Run velvetg
##
## USAGE:         velvetg.sh
##                           dir_prefix         # Output directory prefix of velveth
##                           kmer_start         # Must be odd, inclusive
##                           kmer_end           # Must be odd, inclusive
##                           [cov_cutoff
##                           [insert_length1]
##                           [insert_length2]]
##
## OUTPUT:        
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 3 $# $0

# Process input params
DIRPREFX=$1
KMER_BEG=$2
KMER_END=$3
COV_CUTF=$4
INSERTL1=$5
INSERTL2=$6

# Add options
if [ ! -z "$COV_CUTF" ]; then
  PARAM_COV_CUTF='-cov_cutoff '$COV_CUTF
fi
if [ ! -z "$INSERTL1" ]; then
  PARAM_INSERTL='-ins_length1 '$INSERTL1
fi
if [ ! -z "$INSERTL2" ]; then
  PARAM_INSERTL=$PARAM_INSERTL' -ins_length2 '$INSERTL2
fi

# Run tool
for((n=$KMER_BEG; n<=$KMER_END; n=n+2)); do
  velvetg                      \
    $DIRPREFX"_"$n             \
    -min_contig_lgth 100       \
    $PARAM_COV_CUTF            \
    $PARAM_INSERTL             \
    -read_trkg yes
done &> $DIRPREFX.velvetg.log
