#!/bin/bash
## 
## DESCRIPTION:   Run velvetg
##
## USAGE:         velvetg.sh
##                           dir_prefix         # Output directory prefix of velveth
##                           kmer_start         # Must be odd, inclusive
##                           kmer_end           # Must be odd, inclusive
##                           [min_contig_lgth
##                           [cov_cutoff]
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
MIN_CONT=$4
COV_CUTF=$5
INSERTL1=$6
INSERTL2=$7

# Add options
if [ ! -z "$MIN_CONT" ]; then
  PARAM_MIN_CONT='-min_contig_lgth '$MIN_CONT
fi
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
    -read_trkg yes             \
    $PARAM_MIN_CONT            \
    $PARAM_COV_CUTF            \
    $PARAM_INSERTL
done &> $DIRPREFX.velvetg.log
