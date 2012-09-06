#!/bin/bash
##
## DESCRIPTION:   Count covered bases for normal/tumor pair of bam files using a single node
##                with multiple background processes (num_parallel number of concurrent processes)
##                Note: num_parallel is the maximum.  In reality, less than num_parallel processes
##                      may be used.
##
## USAGE:         music.bmr.calc_covg.sn.sh
##                                          bamlist
##                                          roi_bed_file
##                                          out_dir
##                                          ref.fa
##                                          num_parallel
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
for file in `ls *cmds.fixed.split_*`; do
  bash $file &
done
wait

# Run again to generate total_covgs
$WUSTL_GENOME music bmr calc-covg      \
  --roi-file $ROI_BED                  \
  --reference-sequence $REFEREN        \
  --bam-list $BAMLIST                  \
  --output-dir $OUT_DIR                \
  &> $OUTPUTLOG2
