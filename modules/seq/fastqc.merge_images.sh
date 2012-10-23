#!/bin/bash
##
## DESCRIPTION:   Merge fastqc images.  Must be run inside Project directory containing Sample_X directories
## 
## USAGE:         fastqc.merge_images.sh out_prefix
##
## OUTPUT:        Merged fastqc images prefixed by out_prefix
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

OUTPREFIX=$1

NUM_SAMPLES=`ls | grep Sample_ | wc -l`
montage -font Helvetica -pointsize 20 -label %d Sample_*/*[0-9]_fastqc/Images/per_base_quality.png -geometry 800x610>+2+2 -tile 2x$NUM_SAMPLES $OUTPREFIX.seq.per_base_quality.png
montage -font Helvetica -pointsize 20 -label %d Sample_*/*[0-9]_fastqc/Images/per_sequence_quality.png -geometry 800x610>+2+2 -tile 2x$NUM_SAMPLES $OUTPREFIX.seq.per_sequence_quality.png
