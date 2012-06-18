#!/bin/bash
## 
## DESCRIPTION: Change permissions for all the files and subdirs in a directory
##              To enable read/write from another userid
##
## USAGE: permissions.share.sh [file_permissions [dir_permissions]]
##
## OUTPUT: None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Get params and set defaults
PERM_FILE=$1
PERM_DIR=$2
PERM_FILE=${PERM_FILE:=644}
PERM_DIR=${PERM_DIR:=755}

# Set permissions
echo "Recursively setting file permissions to $PERM_FILE"
find . -type f -exec chmod 0$PERM_FILE {} \;
echo "Recursively setting directory permissions to $PERM_DIR"
find . -type d -exec chmod 0$PERM_DIR {} \;
