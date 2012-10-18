#!/bin/bash
## 
## DESCRIPTION:   Resize an image
##
## USAGE:         resize_image.sh
##                                image.png
##                                new_size(653x420)
##
## OUTPUT:        image.resize.png
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 2 $# $0

# Process input
IMAGE_IN=$1
IMAGE_NEWSIZE=$2

# Format Output
OUTPUTPREFIX=`filter_ext $IMAGE_IN 1`
OUTFILE=$OUTPUTPREFIX.resize.png

# Run tool
convert $IMAGE_IN -resize $IMAGE_NEWSIZE $OUTFILE
#convert -size 653x420 $filepath -resize 653x420 $filepath
