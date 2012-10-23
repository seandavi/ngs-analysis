#!/bin/bash
##
## DESCRIPTION:   Merge bam qc images.  Must be run inside Project directory containing Sample_X directories
## 
## USAGE:         bam.qc.merge_images.sh out_prefix
##
## OUTPUT:        Merged fastqc images prefixed by out_prefix
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 1 $# $0

OUTPREFIX=$1

NUM_SAMPLES=`ls | grep Sample_ | wc -l`
montage -font Helvetica -pointsize 20 -label %d Sample_*/*insertsize.pdf -geometry 504x504>+2+2 $OUTPREFIX.insertsizes.png
