#!/bin/bash


# Echo to standard error
echoerr() {
    echo "$@" 1>&2; 
}

# Create a directory if it doesn't already exist
create_dir() {
    [ ! -d $1 ] && mkdir $1
}

# Check number of input parameters.  If incorrect, output usage information
usage() {
    # $1: Number of parameters needed
    # $2: Actual number of parameters
    # $3: Path to script that's calling this function
    if [ $1 -ne $2 ]; then
     	sed -n '/^##/,/^$/s/^## \{0,1\}//p' $3
       	exit 2
    fi
}

# Filter out multiple extensions of a filename
filter_ext() {
    # $1: Filename
    # $2: Number of extentions to filter
    FILENAME=$1
    COUNTER=$2
    while [ $COUNTER -gt 0 ]
    do
       	FILENAME=${FILENAME%.*}
       	COUNTER=$(($COUNTER-1))
    done
    echo $FILENAME
}