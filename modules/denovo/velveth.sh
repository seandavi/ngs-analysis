#!/bin/bash
## 
## DESCRIPTION:   Run velveth
##
## USAGE:         velveth.sh
##                           out_prefix
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
usage 5 $# $0

# Process input params
OUTPREFIX=$1
SHORT_PE1=$2
SHORT_SE1=$3
SHORT_PE2=$4
SHORT_SE2=$5

velveth                             \
 $OUTPREFIX                         \
 31,43,2                            \
 -fastq -shortPaired1 $SHORT_PE1    \
 -fastq -shortPaired2 $SHORT_PE2    \
 -fastq -short1 $SHORT_SE1          \
 -fastq -short2 $SHORT_SE2          \
  &> $OUTPREFIX.velveth.log
