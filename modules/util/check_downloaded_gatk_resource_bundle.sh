#!/bin/bash
## 
## DESCRIPTION:   Check downloaded GATK resource bundle files by their md5 checksums
##
## USAGE:         check_downloaded_gatk_resource_bundle.sh filenamesfile directory
##
## OUTPUT:        filenamesfile.md5checkfail: List of files that failed the checksum test
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage 2 $# $0

FILESLIST=$PWD/$1
TARGETDIR=$2
OUTPUTFILE=$FILESLIST.md5checkfail

# If target dir does not exist, exit with error
if [ ! -d "$TARGETDIR" ]
then
  echo 'Directory does not exist!'
  exit 1
fi

# Remove existing failed list file
rm -f $OUTPUTFILE

# Check all files and md5
cd $TARGETDIR
for filename in `cat $FILESLIST`; do

  # Compare md5 files with the originals
  if [ `extract_suffix $filename` = 'md5' ] 
  then
    original_file=`filter_suffix $filename`
    md5_original=`md5sum $original_file | cut -f1 -d' '`
    md5_downloaded=`cut -f1 -d' ' $filename`
    echo 'Checking file' $original_file $filename
    if [ "$md5_original" != "$md5_downloaded" ]
    then
	echo $filename >> $OUTPUTFILE
	echo $original_file >> $OUTPUTFILE
    fi
  fi
done
