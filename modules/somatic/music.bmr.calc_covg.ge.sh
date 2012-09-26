#!/bin/bash
##
## DESCRIPTION:   Count covered bases for normal/tumor pair of bam files using grid engine
##                Note: num_jobs is the maximum.  In reality, less number of processes
##                      may be used.
##
## USAGE:         music.bmr.calc_covg.sn.sh
##                                          bamlist
##                                          roi_bed_file
##                                          out_dir
##                                          ref.fa
##                                          num_jobs
##
## OUTPUT:        bamlist.music/
##                  gene_covgs
##                  roi_covgs
##                  total_covgs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 5 $# $0

# Process input parameters
BAMLIST=$1
ROI_BED=$2
OUT_DIR=$3
REFEREN=$4
N_PROCS=$5

# Format output filenames
OUTPUTPREFIX=$OUT_DIR.calc-covg
OUTPUTLOG=$OUTPUTPREFIX.log
OUTPUTLOG2=$OUTPUTPREFIX.2.log

# Create output directory
assert_dir_not_exists $OUT_DIR
mkdir $OUT_DIR

# Run tool
genome music bmr calc-covg              \
  --roi-file $ROI_BED                   \
  --reference-sequence $REFEREN         \
  --bam-list $BAMLIST                   \
  --output-dir $OUT_DIR                 \
  --cmd-list-file $OUTPUTPREFIX.cmds    \
  --cmd-prefix ''                       \
  &> $OUTPUTLOG

# Check if tool ran successfully
assert_normal_exit_status $? "First iteration of bmr calc-covg exited with error"

# Run the parallelized jobs
WUSTL_GENOME=`which genome`
sed "s,gmt,$WUSTL_GENOME," $OUTPUTPREFIX.cmds > $OUTPUTPREFIX.cmds.fixed
NLINES=`wc -l $OUTPUTPREFIX.cmds.fixed | cut -f1 -d ' '`
NLINES_SPLIT=`$PYTHON -c "import math; print int(math.ceil("$NLINES"/float("$N_PROCS")))"`
split -l $NLINES_SPLIT $OUTPUTPREFIX.cmds.fixed $OUTPUTPREFIX.cmds.fixed.split_
# Insert environment variables at the top of each script
for file in `ls *cmds.fixed.split_*`; do
  cat <(echo "source ~/bin/genome.env.sh") $file > tmp.command
  mv -f tmp.command $file
done
# Submit to grid engine
for file in `ls *cmds.fixed.split_*`; do
  $NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh    \
    music.calc_covg                                 \
    all.q                                           \
    1                                               \
    4G                                              \
    none                                            \
    n                                               \
    $file
done

$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh      \
  waiting                                           \
  all.q                                             \
  1                                                 \
  1M                                                \
  music.calc_covg                                   \
  y                                                 \
  $NGS_ANALYSIS_DIR/modules/util/hello_world.sh

# Run again to generate total_covgs
$WUSTL_GENOME music bmr calc-covg      \
  --roi-file $ROI_BED                  \
  --reference-sequence $REFEREN        \
  --bam-list $BAMLIST                  \
  --output-dir $OUT_DIR                \
  &> $OUTPUTLOG2
