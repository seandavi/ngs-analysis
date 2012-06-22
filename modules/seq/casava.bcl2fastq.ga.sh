#!/bin/bash
##
## DESCRIPTION: Generate fastq files from GA experiment results
##              Must be run from within the BaseCalls directory
## 
## USAGE: casava.bcl2fastq.ga.sh output_dir_name path/to/SampleSheet.csv [num_threads]
##
## OUTPUT: directory containing fastq files for each project/sample
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

OUTPUT_DIR=$1
SAMPLESHEET=$2
NUM_THREADS=$3
BCL2FASTQ_NUM_THREADS=${NUM_THREADS:=$BCL2FASTQ_NUM_THREADS}

# Check to make sure that output_directory_name doesn't already exist
if [ -d $OUTPUT_DIR ]; then
  echoerr "Error: Output directory $OUTPUT_DIR already exists"
  exit 1
fi

# Check to make sure that samplesheet exists
if [ ! -f $SAMPLESHEET ]; then
  echoerr "Error: Sample sheet file $SAMPLESHEET does not exist!"
  exit 1
fi

# Setup basecalling makefile
BASECALLS_DIR=$PWD
FASTQ_CLUSTER_COUNT=0
$BCL2FASTQ                                                 \
  --input-dir $BASECALLS_DIR                               \
  --intensities-dir $BASECALLS_DIR/../                     \
  --positions-format _pos.txt                              \
  --fastq-cluster-count $FASTQ_CLUSTER_COUNT               \
  --sample-sheet $SAMPLESHEET                              \
  --output-dir $OUTPUT_DIR >& $BASECALLS_DIR/configureBclToFastq.log


# Go into output directory, and run the makefile
cd $OUTPUT_DIR
nohup make -j $BCL2FASTQ_NUM_THREADS
