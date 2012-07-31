#!/bin/bash
## 
## DESCRIPTION:   Wrap a command with qsub submitting parameters
##
## USAGE:         qsub_wrapper.sh 
##                                job_id
##                                queue_id
##                                num_parallel
##                                memory_needed(i.e. 8G)
##                                dependent_job_id
##                                command [param1 [param2 [...]]]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 2 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
JOBID=${PARAMS[0]}
QUEUE=${PARAMS[1]}
NUMPP=${PARAMS[2]}
MEMSZ=${PARAMS[3]}
WAIT4=${PARAMS[4]}
LEN_COMMD=$(($NUM_PARAMS - 5))
COMMD=${PARAMS[@]:5:$LEN_COMMD}

# Make temporary files folder
TMP=tmp.$JOBID.$RANDOM
mkdir $TMP

# Submit command
OPTION_V='NGS_ANALYSIS_CONFIG='$NGS_ANALYSIS_CONFIG
OPTION_V=$OPTION_V',NGS_ANALYSIS_DIR='$NGS_ANALYSIS_DIR
OPTION_V=$OPTION_V',PATH='$PATH
OPTION_V=$OPTION_V',PYTHONPATH='$PYTHONPATH
qsub                                             \
  -cwd                                           \
  -hold_jid $WAIT4                               \
  -N $JOBID                                      \
  -v $OPTION_V                                   \
  -S /bin/bash                                   \
  -j y                                           \
  -o $TMP                                        \
  -e $TMP                                        \
  -pe orte $NUMPP                                \
  -l h_vmem=$MEMSZ                               \
  -q $QUEUE                                      \
  $COMMD

#
# #$ -cwd
# #$ -v PATH
# #$ -S /bin/bash
# #$ -j y
# #$ -o .
# #$ -e .
# #$ -pe orte 2
# #$ -l mem=8G
# #$ -q all.q
#
