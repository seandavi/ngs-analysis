#!/bin/bash
## 
## DESCRIPTION:   Run varscan on normal/tumor pairs.
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##
## USAGE:         ngs.pipe.varscan.somatic.vcf.sh
##                                                bamlist
##                                                somatic_pval
##                                                tumor_purity
##                                                [min_cov_normal (default 10)
##                                                [min_cov_tumor  (default 6)  ]
##                                                [num_parallel   (default 20) ]]
##
## OUTPUT:        varscan/ directory containing varscan output files for all sample pairs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input parameters
BAMLIST=$1
SOMPVAL=$2
TPURITY=$3
MINCOVN=$4
MINCOVT=$5
NUM_PAR=$6
MINCOVN=${MINCOVN:=10}
MINCOVT=${MINCOVT:=6}
NUM_PAR=${NUM_PAR:=20}

# Make sure that bamlist file exists
assert_file_exists_w_content $BAMLIST

# Create varscan output directory
mkdir varscan

# Run VarScan
P=0
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`
  # Make sure that pileups exist for the bam pairs
  assert_file_exists_w_content $BAM_N.mpileup
  assert_file_exists_w_content $BAM_T.mpileup
  echo "Processing sample: "$SAMPL
  $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
    $BAM_N.mpileup                                                        \
    $BAM_T.mpileup                                                        \
    varscan/$SAMPL                                                        \
    $SOMPVAL                                                              \
    $TPURITY                                                              \
    $MINCOVN                                                              \
    $MINCOVT &
  # Maintain parallel processes
  P=$((P + 1))
  if [ $P -ge $NUM_PAR ]; then
    wait
    P=0
  fi
done
wait
