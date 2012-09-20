#!/bin/bash
## 
## DESCRIPTION:   Run varscan on normal/tumor pairs.
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##
## USAGE:         ngs.pipe.varscan.somatic.vcf.sh
##                                                bamlist
##                                                somatic_pval
##                                                tumor_purity
##                                                num_parallel
##
## OUTPUT:        varscan/ directory containing varscan output files for all sample pairs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 4 $# $0

# Process input parameters
BAMLIST=$1
SOMPVAL=$2
TPURITY=$3
NUM_PAR=$4

assert_file_exists_w_content $BAMLIST

# Run VarScan
P=0
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`
  # Make sure that pileups exist for the bam pairs
  assert_file_exists_w_content $BAM_N.mpileup
  assert_file_exists_w_content $BAM_T.mpileup
  $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
    $BAM_N.mpileup                                                        \
    $BAM_T.mpileup                                                        \
    varscan/$SAMPL                                                        \
    $SOMPVAL                                                              \
    $TPURITY &
  # Maintain parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PAR ]; then
    wait
    P=0
  fi
done
wait
