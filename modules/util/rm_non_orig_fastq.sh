#!/bin/bash
## 
## DESCRIPTION:   Remove all files in a directory except for the original fastq.gz files
##                from Illumina Hiseq basecalling
##
## USAGE:         rm_non_orig_fastq.sh
##                                     dirname
##                                     [num_parallel]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check usage
usage_min 1 $# $0

# Get params and set defaults
TARGETDIR=$1
NUM_PROCS=$2

# Check if directory exists
assert_dir_exists $TARGETDIR

# Set default number of parallel processes
NUM_PROCS=${NUM_PROCS:=1}

# Remove files
cd $TARGETDIR
P=0
for file in `find . -not -name "*_*_L???_R?_???.fastq.gz"`; do
  # Skip '.' or '..'
  [ $file == '.' ] && continue
  [ $file == '..' ] && continue
  # Remove file
  rm -rf $file &
  # Maintain parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PROCS ]; then
    wait
    P=0
  fi
done
wait

