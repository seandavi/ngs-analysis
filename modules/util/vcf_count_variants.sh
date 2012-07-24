#!/bin/bash
## 
## DESCRIPTION:   Count number of records (variants, i.e. lines) in a vcf file
##
## USAGE:         vcf_count_variants.sh input.vcf
##
## OUTPUT:        Number of lines in a vcf file that is not prefixed by a '#'
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 1 $# $0

# PROCESS INPUT PARAMS
INPUTVCF=$1

grep -v ^# $INPUTVCF | wc -l