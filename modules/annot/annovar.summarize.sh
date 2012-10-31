#!/bin/bash
##
## DESCRIPTION:   Run ANNOVAR
##
## USAGE:         annovar.summarize.sh sample.vcf
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

# Convert to annovar input
$ANNOVAR_PATH/convert2annovar.pl     \
  -includeinfo                       \
  -format vcf4                       \
  $VCF_IN                            \
  1> $OUTPRE.in                      \
  2> $OUTPRE.in.err

# Check if conversion tool ran successfully
assert_normal_exit_status $? "convert2annovar.pl exited with error"

# Run tool
$ANNOVAR_PATH/summarize_annovar.pl   \
  --outfile $OUTPRE.summarize        \
  --buildver hg19                    \
  --verdbsnp 135                     \
  --ver1000g 1000g2010nov            \
  $OUTPRE.in                         \
  $ANNOVAR_HUMANDB                   \
  &> $OUTPRE.summarize.log

# Check if ANNOVAR ran successfully
assert_normal_exit_status $? "summarize_annovar.pl exited with error"

# Convert output to vcf
#cut -f 3- $OUTPRE.summarize > $OUTPRE.summarize.vcf

