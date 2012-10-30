#!/bin/bash
## 
## DESCRIPTION:   Count number of records (variants, i.e. lines) in a vcf file
##
## USAGE:         vcf_count_variants.sh in1.vcf [in2.vcf [...]]
##
## OUTPUT:        Number of lines in a vcf file that is not prefixed by a '#'
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 1 $# $0

# Process input params
VCFFILES=$@

for file in $VCFFILES; do
  echo -e `grep -v ^# $file | wc -l` "\t"$file
done