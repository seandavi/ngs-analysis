#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, generate a single combined TCGA maf file
##                Use grid engine using qsub
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##
## USAGE:         ngs.pipe.bam2maf.ge.sh bamlist ref.fasta maf_out_prefix
##
## OUTPUT:        maf_out_prefix.maf
##                VarScan output in varscan/ directory
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 3 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
OUT_PRE=$3

# Create temporary directory
TMPDIR=tmp.bam2maf.$RANDOM
mkdir $TMPDIR

# Run samtools mpileup
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh
for bamfile in `cat <(cut -f2 $BAMLIST) <(cut -f3 $BAMLIST)`; do
  $QSUB mpileup.$SAMPL                                                          \
        all.q                                                                   \
        1                                                                       \
        1G                                                                      \
        none                                                                    \
        $NGS_ANALYSIS_DIR/modules/align/samtools.mpileup.sh $bamfile $REFEREN "-Q 30"
done

# Run varscan, annotate, and create maf files
mkdir varscan
SOMATIC_PVAL=0.05
TUMOR_PURITY=1.0
GENE2ENTREZ=$NGS_ANALYSIS_DIR/resources/gene2entrezid
for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
  SAMPL=`echo $bamfiles | cut -f1 -d':'`
  BAM_N=`echo $bamfiles | cut -f2 -d':'`
  BAM_T=`echo $bamfiles | cut -f3 -d':'`

  # Run VarScan
  $QSUB varscan.$SAMPL                                                          \
        all.q                                                                   \
        1                                                                       \
        32G                                                                     \
        mpileup.$SAMPL                                                          \
        $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
          $BAM_N.mpileup                                                        \
          $BAM_T.mpileup                                                        \
          varscan/$SAMPL                                                        \
          $SOMATIC_PVAL                                                         \
          $TUMOR_PURITY

  # Convert varscan output to maf
  $QSUB varscan.vcf2maf                                                         \
        all.q                                                                   \
        1                                                                       \
        4G                                                                      \
        varscan.$SAMPL                                                          \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.varscan.vcf2maf.sh                 \
          $SAMPL                                                                \
          varscan/$SAMPL.snp.vcf                                                \
          varscan/$SAMPL.indel.vcf
done


# Merge all mafs
$QSUB merge.maf                                                                 \
      all.q                                                                     \
      1                                                                         \
      1G                                                                        \
      varscan.vcf2maf                                                           \
      $NGS_ANALYSIS_DIR/modules/somatic/merge_maf.sh $OUT_PRE varscan/*maf
