#!/bin/bash
## 
## DESCRIPTION:   Wrap a command with qsub submitting parameters
##
## USAGE:         qsub_wrapper.sh 
##                                job_id
##                                queue_id
##                                num_parallel
##                                dependent_job_id
##                                sync(wait to finish, y|n)
##                                command [param1 [param2 [...]]]
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 6 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
JOBID=${PARAMS[0]}
QUEUE=${PARAMS[1]}
NUMPP=${PARAMS[2]}
WAIT4=${PARAMS[3]}
SYNC=${PARAMS[4]}
LEN_COMMD=$(($NUM_PARAMS - 5))
COMMD=${PARAMS[@]:5:$LEN_COMMD}

# Make temporary files folder
create_dir tmp
TMP=tmp/tmp.$JOBID.$RANDOM
mkdir $TMP

# Record qsub parameters
echo JOBID $JOBID >> $TMP/qsub_wrapper.params
echo QUEUE $QUEUE >> $TMP/qsub_wrapper.params
echo NUMPP $NUMPP >> $TMP/qsub_wrapper.params
echo WAIT4 $WAIT4 >> $TMP/qsub_wrapper.params
echo SYNC  $SYNC  >> $TMP/qsub_wrapper.params
echo COMMD $COMMD >> $TMP/qsub_wrapper.params

# Submit command
qsub                                             \
  -cwd                                           \
  -hold_jid $WAIT4                               \
  -N $JOBID                                      \
  -V                                             \
  -S /bin/bash                                   \
  -j y                                           \
  -o $TMP                                        \
  -e $TMP                                        \
  -pe orte $NUMPP                                \
  -q $QUEUE                                      \
  -sync $SYNC                                    \
  $COMMD

sleep 3

#
# #$ -cwd
# #$ -N jobid
# #$ -v PATH
# #$ -S /bin/bash
# #$ -j y
# #$ -o .
# #$ -e .
# #$ -pe orte 2
# #$ -l h_vmem=8G
# #$ -q all.q
#
