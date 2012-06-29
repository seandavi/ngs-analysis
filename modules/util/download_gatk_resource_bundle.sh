#!/bin/bash
## 
## DESCRIPTION:   Download resource bundle from GATK ftp site
##
## USAGE:         download_gatk_resource_bundle.sh path/to/ftp/directory filenamesfile [TARGET_DIR]
##
## OUTPUT:        GATK resource bundle files
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 2 $# $0

FTPDIR=$1
FILESLIST=$2
TARGETDIR=$3
TARGETDIR=${TARGETDIR:='.'}

# If target dir does not exist, then create it
if [ ! -d $TARGET_DIR ]
then
  mkdir $TARGET_DIR
fi

# Download the files
for filename in `cat $FILESLIST`; do
  echo $filename
done