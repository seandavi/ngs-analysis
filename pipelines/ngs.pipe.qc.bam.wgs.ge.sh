#!/bin/bash
##
## DESCRIPTION:   Run some qc tools on a bam file
## 
## USAGE:         ngs.pipe.qc.bam.wgs.ge.sh
##                                          (HG|B3x)
##                                          in1.bam
##                                          [in2.bam [...]]
##
## OUTPUT:        QC outputs for each bam file inputted
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 2 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
RESOURCE_T=${PARAMS[0]}
NUM_BAMFLS=$(($NUM_PARAMS - 1))
BAM_FILES=${PARAMS[@]:1:$NUM_BAMFLS}

# Set resource vars
if [ $RESOURCE_T = 'HG' ]; then
  REF=$HG_REF
else
  REF=$B3x_REF
fi

QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh
# Depth of coverage for alignment to entire genome
$QSUB depthofcov                                                                   \
      all.q                                                                        \
      1                                                                            \
      none                                                                         \
      n                                                                            \
      $NGS_ANALYSIS_DIR/modules/align/gatk.depthofcoverage.wgs.sh                  \
        $REF                                                                       \
	samples                                                                    \
	$BAM_FILES

for bamfile in $BAM_FILES; do
  # QualityScoreDistribution
  $QSUB qscoredist                                                                 \
        all.q                                                                      \
        1                                                                          \
        none                                                                       \
        n                                                                          \
        $NGS_ANALYSIS_DIR/modules/align/picard.qualityscoredistribution.sh         \
	  $bamfile
  # CollectGcBiasMetrics
  $QSUB gcbias                                                                     \
        all.q                                                                      \
        1                                                                          \
        none                                                                       \
        n                                                                          \
        $NGS_ANALYSIS_DIR/modules/align/picard.collectgcbiasmetrics.sh             \
	  $bamfile                                                                 \
          $REF
  # CollectInsertSizeMetrics
  $QSUB insertsize                                                                 \
        all.q                                                                      \
        1                                                                          \
        none                                                                       \
        n                                                                          \
        $NGS_ANALYSIS_DIR/modules/align/picard.collectinsertsizemetrics.sh         \
	  $bamfile
  # MeanQualityByCycle
  $QSUB meanqbycycle                                                               \
        all.q                                                                      \
        1                                                                          \
        none                                                                       \
        n                                                                          \
        $NGS_ANALYSIS_DIR/modules/align/picard.meanqualitybycycle.sh               \
	  $bamfile
  # CollectAlignmentSummaryMetrics
  $QSUB alignsummetric                                                             \
        all.q                                                                      \
        1                                                                          \
        none                                                                       \
        n                                                                          \
        $NGS_ANALYSIS_DIR/modules/align/picard.collectalignmentsummarymetrics.sh   \
	  $bamfile
done
