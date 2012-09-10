#!/bin/bash
## 
## DESCRIPTION:   Wrap a command with bash, useful for wrapping binary tool commands
##                in order to submit to grid engine using qsub
##
## USAGE:         bash_wrapper.sh "command string"
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 1 $# $0

# Run the command described by the parameter
$@