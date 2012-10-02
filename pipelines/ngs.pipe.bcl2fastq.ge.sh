#!/bin/bash
##
## DESCRIPTION:   Generate fastq files from Hiseq experiment results
##                Must be run from within the BaseCalls directory
## 
## USAGE:         ngs.pipe.bcl2fastq.ge.sh
##                                             output_dir_name
##                                             path/to/SampleSheet.csv
##                                             [num_threads]
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
NUM_THREADS=${NUM_THREADS:=20}

# Check to make sure that output_directory_name doesn't already exist
assert_dir_not_exists $OUTPUT_DIR

# Check to make sure that samplesheet exists
assert_file_exists_w_content $SAMPLESHEET

# Samplesheet sanity check
$PYTHON $NGS_ANALYSIS_DIR/modules/seq/illumina_samplesheet_sanitycheck.py $SAMPLESHEET

# Check if tool ran successfully
assert_normal_exit_status $? "Invalid samplesheet"

# Setup basecalling makefile
BASECALLS_DIR=$PWD
FASTQ_CLUSTER_COUNT=0
$BCL2FASTQ                                                 \
  --input-dir $BASECALLS_DIR                               \
  --intensities-dir $BASECALLS_DIR/../                     \
  --positions-format .clocs                                \
  --fastq-cluster-count $FASTQ_CLUSTER_COUNT               \
  --sample-sheet $SAMPLESHEET                              \
  --output-dir $OUTPUT_DIR                                 \
  >& $BASECALLS_DIR/configureBclToFastq.log

# Check if tool ran successfully
assert_normal_exit_status $? "configureBclToFastq exited with error"

# Go into output directory, and run the makefile
cd $OUTPUT_DIR
BASH_WRAPPER=$NGS_ANALYSIS_DIR/modules/util/bash_wrapper.sh
qsub_wrapper.sh                                            \
  bcl2fastq                                                \
  all.q                                                    \
  $NUM_THREADS                                             \
  8G                                                       \
  none                                                     \
  y                                                        \
  $BASH_WRAPPER `which make` -j $NUM_THREADS
