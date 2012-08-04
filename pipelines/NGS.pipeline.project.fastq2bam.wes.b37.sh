#!/bin/bash
## 
## DESCRIPTION:   Run alignment pipeline on each sample directory
##
## USAGE:         NGS.pipeline.project.fastq2bam.wes.b37.sh Sample_X [Sample_Y [...]]
##
## OUTPUT:        Alignment files in each sample directory
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

# Submit each sample directory to the grid engine
SAMPLEDIRS=$@
for sampledir in $SAMPLEDIRS; do
  SAMPLENAME=`echo $sampledir | cut -f2- -d'_'`
  qsub_wrapper.sh                                                   \
    $SAMPLENAME.fastq2bam                                           \
    all.q                                                           \
    4                                                               \
    16G                                                             \
    none                                                            \
    $NGS_ANALYSIS_DIR/pipelines/NGS.pipeline.fastq2bam.wes.b37.sh   \
      $sampledir                                                    \
      $B3x_REF                                                      \
      $B3x_DBSNP_VCF                                                \
      $B3x_MILLS_INDELS_SITES_VCF                                   \
      $B3x_1000G_INDELS_PHASE1_VCF
done