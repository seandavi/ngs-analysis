#!/bin/bash
##
## DESCRIPTION:   Run ANNOVAR
##
## USAGE:         annovar.sh sample.vcf
##
## OUTPUT:        sample.annovar.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

# Process input parameters
VCF_IN=$1

# Format outputs
OUTPRE=`filter_ext $VCF_IN 1`.annovar
VCFOUT=$OUTPRE.vcf

# Convert to annovar input
$ANNOVAR_CONVERT                     \
  -includeinfo                       \
  -format vcf4                       \
  $VCF_IN                            \
  1> $OUTPRE.in                      \
  2> $OUTPRE.in.err

# Check if conversion tool ran successfully
assert_normal_exit_status $? "convert2annovar.pl exited with error"

# Run tool
$ANNOVAR                             \
  -geneanno                          \
  $OUTPRE.in                         \
  $ANNOVAR_HUMANDB                   \
  --outfile $OUTPRE                  \
  &> $OUTPRE.variant_function.log

# Check if ANNOVAR ran successfully
assert_normal_exit_status $? "ANNOVAR exited with error"

# Convert output to vcf
cut -f 3- $OUTPRE.variant_function > $OUTVCF

