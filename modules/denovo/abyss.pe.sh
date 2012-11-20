#!/bin/bash
## 
## DESCRIPTION:   Run abyss-pe
##
## USAGE:         abyss.pe.sh
##                            prefix               # Run prefix
##                            kmer_start
##                            kmer_end
##                            num_threads
##                            sample1.pe.r1.fastq
##                            sample1.pe.r2.fastq
##                            sample2.pe.r1.fastq
##                            sample2.pe.r2.fastq
##                            sample1.se.fastq
##                            sample2.se.fastq
##
## OUTPUT:        
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Usage check:
usage_min 10 $# $0

# Process input params
R_PREFIX=$1
KMER_BEG=$2
KMER_END=$3
N_THREAD=$4
S1_PE_R1=$5
S1_PE_R2=$6
S2_PE_R1=$7
S2_PE_R2=$8
S1_SE=$9
S2_SE=${10}

export k
for((k=$KMER_BEG; k<=$KMER_END; k=k+2)); do
    WDIRNAME='k'$k
    mkdir $WDIRNAME
    abyss-pe                               \
      -C  $WDIRNAME                        \
      -j $N_THREAD                         \
      k=$k                                 \
      name=$R_PREFIX                       \
      lib='pe1 pe2'                        \
      pe1="../$S1_PE_R1 ../$S1_PE_R2"      \
      pe2="../$S2_PE_R1 ../$S2_PE_R2"      \
      se="../$S1_SE ../$S2_SE"
done &> $R_PREFIX.abyss.pe.log
abyss-fac k*/$R_PREFIX-contigs.fa > $R_PREFIX.abyss.pe.stats
