#!/bin/bash
## 
## DESCRIPTION:   Run GATK SomaticIndelDetector and generate maf files
##                Bamlist must be in the format specified by wustl genome music
##
## USAGE:         ngs.pipe.bam2maf.gatk.somaticindel.ge.sh
##                                                          bamlist
##                                                          ref
##                                                          snpeff_genome_version(i.e. 37.64)
##
## OUTPUT:        mpileups for the bamfiles listed in bamlist
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 3 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
SNPEFFV=$3

# Set up output directory
OUTDIR=gatk.somaticindeldetector
mkdir $OUTDIR

# Run GATK SomaticIndelDetector
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`
  $QSUB gatk.somaticindeldetector.$SAMPL                                                \
        all.q                                                                           \
        1                                                                               \
        4G                                                                              \
        none                                                                            \
        n                                                                               \
        $NGS_ANALYSIS_DIR/modules/somatic/gatk.somaticindeldetector.sh                  \
          $BAM_N                                                                        \
          $BAM_T                                                                        \
          $SAMPL                                                                        \
          $REFEREN                                                                      \
          $OUTDIR/$SAMPL

  # Generate maf
  $QSUB vcf2maf                                                                         \
        all.q                                                                           \
        1                                                                               \
        5G                                                                              \
        gatk.somaticindeldetector.$SAMPL                                                \
        n                                                                               \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.gatk.somaticindeldetector.sh       \
          $SAMPL                                                                        \
          $OUTDIR/$SAMPL.vcf                                                            \
          $SNPEFFV
done
