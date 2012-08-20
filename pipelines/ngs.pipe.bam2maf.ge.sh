#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, generate a single combined TCGA maf file
##                Use grid engine using qsub
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##
## USAGE:         ngs.pipe.bam2maf.ge.sh bamlist ref.fasta maf_out_prefix [snpeff_genome_version(default GRCh37.64)]
##
## OUTPUT:        maf_out_prefix.maf
##                VarScan output in varscan/ directory
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 3 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
OUT_PRE=$3
SNPEFFV=$4

# Create temporary directory
RNUM=$RANDOM
TMPDIR=tmp.bam2maf.$RNUM
mkdir $TMPDIR

# Qsub wrapper path
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh

# Run samtools mpileup
cat <(cut -f2 $BAMLIST) <(cut -f3 $BAMLIST) > $TMPDIR/bamfileslist
$NGS_ANALYSIS_DIR/pipelines/ngs.pipe.mpileup.ge.sh $TMPDIR/bamfileslist $REFEREN mpileup.$RNUM -Q 30

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
        mpileup.$RNUM                                                           \
        $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
          $BAM_N.mpileup                                                        \
          $BAM_T.mpileup                                                        \
          varscan/$SAMPL                                                        \
          $SOMATIC_PVAL                                                         \
          $TUMOR_PURITY

  # Convert varscan snp output to maf
  $QSUB varscan.vcf2maf                                                         \
        all.q                                                                   \
        1                                                                       \
        5G                                                                      \
        varscan.$SAMPL                                                          \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.varscan.snp.sh             \
          $SAMPL                                                                \
          varscan/$SAMPL.snp.vcf                                                \
          $SNPEFFV

  # Convert varscan indel output to maf
  $QSUB varscan.vcf2maf                                                         \
        all.q                                                                   \
        1                                                                       \
        5G                                                                      \
        varscan.$SAMPL                                                          \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.varscan.indel.sh           \
          $SAMPL                                                                \
          varscan/$SAMPL.indel.vcf                                              \
          $SNPEFFV

done


# Merge all mafs
$QSUB merge.maf                                                                 \
      all.q                                                                     \
      1                                                                         \
      1G                                                                        \
      varscan.vcf2maf                                                           \
      $NGS_ANALYSIS_DIR/modules/somatic/merge_maf.sh $OUT_PRE varscan/*maf
