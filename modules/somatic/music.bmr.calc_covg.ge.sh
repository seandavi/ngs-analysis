#!/bin/bash
##
## DESCRIPTION:   Count covered bases for normal/tumor pair of bam files
##
## USAGE:         music.bmr.calc_covg.sh bamlist roi_bed_file out_dir ref.fa
##
## OUTPUT:        bamlist.music/
##                  gene_covgs
##                  roi_covgs
##                  total_covgs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 4 $# $0

# Process input parameters
BAMLIST=$1
ROI_BED=$2
OUT_DIR=$3
REFEREN=$4

# Format output filenames
OUTPUTPREFIX=$OUT_DIR.calc-covg
OUTPUTLOG=$OUTPUTPREFIX.log

# Create output directory
assert_dir_not_exists $OUT_DIR
mkdir $OUT_DIR

# Run tool
OPTION_V='PERL5LIB='$PERL5LIB',PERL_LOCAL_LIB_ROOT='$PERL_LOCAL_LIB_ROOT
genome music bmr calc-covg              \
  --roi-file $ROI_BED                   \
  --reference-sequence $REFEREN         \
  --bam-list $BAMLIST                   \
  --output-dir $OUT_DIR                 \
  --cmd-list-file $OUTPUTPREFIX.cmds    \
  --cmd-prefix 'qsub -cwd                    \
                     -N music.bmr.calc-covg  \
                     -S /bin/bash            \
                     -j y                    \
                     -o .                    \
                     -e .                    \
                     -q all.q                \
                     -v '$OPTION_V           \
  &> $OUTPUTLOG

# Check if tool ran successfully
if [ $? -ne 0 ]; then
  exit 1
fi

# Run the parallelized jobs
WUSTL_GENOME=`which genome`
sed "s,gmt,$WUSTL_GENOME," $OUTPUTPREFIX.cmds > $OUTPUTPREFIX.cmds.fixed
/bin/bash $OUTPUTPREFIX.cmds.fixed

# Run again to generate total_covgs
qsub -cwd -N music.bmr.calc-covg2 -S /bin/bash -j y -o . -e . -q all.q -hold_jid music.bmr.calc-covg -v $OPTION_V \
$WUSTL_GENOME music bmr calc-covg      \
  --roi-file $ROI_BED                  \
  --reference-sequence $REFEREN        \
  --bam-list $BAMLIST                  \
  --output-dir $OUT_DIR                \
