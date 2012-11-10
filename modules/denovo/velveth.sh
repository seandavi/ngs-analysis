#!/bin/bash
## 
## DESCRIPTION:   Run velveth
##
## USAGE:         velveth.sh
##                           out_prefix
##                           kmer_start   # inclusive
##                           kmer_end     # inclusive
##                           sample1.shortpaired.fastq
##                           sample1.shortsingle.fastq
##                           sample2.shortpaired.fastq
##                           sample2.shortsingle.fastq
##
## OUTPUT:        
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 7 $# $0

# Process input params
OUTPREFIX=$1
KMER_BEG=$2
KMER_END=$3
SHORT_PE1=$4
SHORT_SE1=$5
SHORT_PE2=$6
SHORT_SE2=$7

velveth                             \
 $OUTPREFIX                         \
 $KMER_BEG,$(($KMER_END + 2)),2     \
 -fastq -shortPaired1 $SHORT_PE1    \
 -fastq -shortPaired2 $SHORT_PE2    \
 -fastq -short1 $SHORT_SE1          \
 -fastq -short2 $SHORT_SE2          \
  &> $OUTPREFIX.velveth.log
