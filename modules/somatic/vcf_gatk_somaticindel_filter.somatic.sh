#!/bin/bash
## 
## DESCRIPTION:   Select somatic indels from the vcf formatted output of GATK SomaticIndelDetector
##
## USAGE:         vcf_gatk_somaticindel_filter.somatic.sh input.vcf
##
## OUTPUT:        input.somatic.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 1 $# $0

# PROCESS INPUT PARAMS
INPUTVCF=$1
OUTPREFIX=`filter_ext $INPUTVCF 1`
OUTPUTVCF=$OUTPREFIX.somatic.vcf

cat <(grep ^# $INPUTVCF) <(grep -v ^# $INPUTVCF | grep SOMATIC) > $OUTPUTVCF