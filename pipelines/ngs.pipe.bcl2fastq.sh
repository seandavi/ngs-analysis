#!/bin/bash
## 
## DESCRIPTION:   Run Hiseq base calling from within BaseCalls directory
##
## USAGE:         ngs.pipe.bcl2fastq.sh
##                                      output_dir
##                                      path/to/SampleSheet.csv
##                                      [num_threads]
##
## OUTPUT:        directory containing fastq files for each project/sample
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

OUTPUT_DIR=$1
SAMPLESHEET=$2
NUM_THREADS=$3

# Samplesheet sanity check
$PYTHON $NGS_ANALYSIS_DIR/modules/seq/illumina_samplesheet_sanitycheck.py $SAMPLESHEET

# Check if tool ran successfully
assert_normal_exit_status $? "Invalid samplesheet"

# Run basecall
$NGS_ANALYSIS_DIR/modules/seq/casava.bcl2fastq.hiseq.sh $OUTPUT_DIR $SAMPLESHEET $NUM_THREADS
