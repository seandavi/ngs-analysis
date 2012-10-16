#!/bin/bash
## 
## DESCRIPTION:   Remove all non-original fastq.gz files within multiple
##                sample directories within a Hiseq project directory
##
## USAGE:         ngs.pipe.reset.proj.ge.sh Sample_X [Sample_Y [...]]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

# Submit each sample directory to the grid engine
SAMPLEDIRS=$@
for sampledir in $SAMPLEDIRS; do
  sampledir=`echo $sampledir | sed 's/\/$//'`
  SAMPLENAME=`echo $sampledir | cut -f2- -d'_'`
  qsub_wrapper.sh                                                   \
    $SAMPLENAME.reset                                               \
    all.q                                                           \
    4                                                               \
    none                                                            \
    n                                                               \
    $NGS_ANALYSIS_DIR/modules/util/rm_non_orig_fastq.sh             \
      $sampledir                                                    \
      4
done