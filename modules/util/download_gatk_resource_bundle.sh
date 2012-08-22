#!/bin/bash
## 
## DESCRIPTION:   Download resource bundle from GATK ftp site
##                Be sure to get the ftp path by right clicking on a file, not the url
##
## USAGE:         download_gatk_resource_bundle.sh path/to/ftp/directory filenamesfile [TARGET_DIR]
##
## OUTPUT:        GATK resource bundle files
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 2 $# $0

FTPDIR=$1
FILESLIST=$PWD/$2
TARGETDIR=$3
TARGETDIR=${TARGETDIR:='.'}

# If target dir does not exist, then create it
if [ ! -d "$TARGETDIR" ]
then
  mkdir $TARGETDIR
fi

# Download the files
cd $TARGETDIR
for filename in `cat $FILESLIST`; do
  wget $FTPDIR/$filename
  sleep 5m
done
