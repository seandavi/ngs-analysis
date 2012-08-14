#!/bin/bash
## 
## DESCRIPTION:   Copy a hiseq run folder.
##                If lanes is specified, copy only the data
##                pertaining to those lanes
##
## USAGE:         hiseq.run.copy.sh run_folder output_folder num_parallel lanes(i.e. 1 2 3 4 5 6 7 8)
##
## OUTPUT:        None
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 4 $# $0

ORIGIN=$1
OUTDIR=$2
NUM_PARALLEL=$3
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
NUM_LANES=$(($NUM_PARAMS - 3))
LANES=${PARAMS[@]:3:$NUM_LANES}

# Create output directory
create_dir_nonexist $OUTDIR
cd $OUTDIR

# Start with base directory
P=0
for item in `ls $ORIGIN`; do
  if [ $item != "Data" ]; then
    cp -R $ORIGIN/$item . &
    P=$((P + 1))
    if [ $P -ge $NUM_PARALLEL ]; then
      wait
      P=0
    fi
  fi
done

# Check successful run
if [ $? -ne 0 ]; then
  echoerr "Could not copy items in base directory. Exiting"
  exit 1   
fi

# Copy Data directory
create_dir_nonexist Data
cd Data
for item in `ls $ORIGIN/Data`; do
  if [ $item != "Intensities" ]; then
    cp -R $ORIGIN/Data/$item . &
    P=$((P + 1))
    if [ $P -ge $NUM_PARALLEL ]; then
      wait
      P=0
    fi
  fi
done

# Check successful run
if [ $? -ne 0 ]; then
  echoerr "Could not copy items in 'Data' directory. Exiting"
  exit 1   
fi

# Copy Intensities directory
create_dir_nonexist Intensities
cd Intensities
ITEMS='config.xml Offsets RTAConfiguration.xml'
for item in $ITEMS; do
  cp -R $ORIGIN/Data/Intensities/$item . &
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done

for lane in $LANES; do
  cp -R $ORIGIN/Data/Intensities/L00$lane . &
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done

for lane in $LANES; do
  cp $ORIGIN/Data/Intensities/s_$lane*pos.txt . &
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done

# Check successful run
if [ $? -ne 0 ]; then
  echoerr "Could not copy items in 'Intensities' directory. Exiting"
  exit 1   
fi

# Copy BaseCalls directory
create_dir_nonexist BaseCalls
cd BaseCalls
ITEMS='config.xml Matrix Phasing'
for item in $ITEMS; do
  cp -R $ORIGIN/Data/Intensities/BaseCalls/$item . &
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done

for lane in $LANES; do
  cp -R $ORIGIN/Data/Intensities/BaseCalls/L00$lane . &
  P=$((P + 1))
  if [ $P -ge $NUM_PARALLEL ]; then
    wait
    P=0
  fi
done

# Wait for all processes to finish before exiting
wait