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
# Checks to see if the number of parameters is == number of needed parameters
usage() {
    # $1: Number of parameters needed
    # $2: Actual number of parameters
    # $3: Path to script that's calling this function
    if [ $1 -ne $2 ]; then
     	sed -n '/^##/,/^$/s/^## \{0,1\}//p' $3
       	exit 2
    fi
}

# Check number of input parameters.  If incorrect, output usage information
# Checks to see if the number of parameters is >= number of needed parameters
usage_min() {
    # $1: Number of parameters needed
    # $2: Actual number of parameters
    # $3: Path to script that's calling this function
    if [ $1 -gt $2 ]; then
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

# Extract prefix of filenames
extract_prefix() {
    # $1: Filename
    # $2: Number of prefixes to extract
    NUMPREFIX=$2
    NUMPREFIX=${NUMPREFIX:=1}
    echo `echo $1 | cut -f-$NUMPREFIX -d'.'`
}

# Extract extension
extract_suffix() {
    # $1: Filename
    echo $1 | awk -F"." '{ print $NF }'
}

# Filter out the extension
filter_suffix() {
    # $1: Filename
    suffix=`extract_suffix $1`
    echo $1 | sed 's/\.'$suffix'$//'
}