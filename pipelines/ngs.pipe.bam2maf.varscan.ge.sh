#!/bin/bash
## 
## DESCRIPTION:   From a list of bamfiles, generate a single combined TCGA maf file
##                Use grid engine using qsub
##                Bamlist should be given in the format specified by MuSiC (WUSTL)
##                Set the single_transcript flag to use only a single transcript per
##                gene.  Transcript will be selected based on the number of annotated
##                HIGH impact effect mutations.
##                If single_transcript is not set, by default will use merged transcripts.
##
## USAGE:         ngs.pipe.bam2maf.varscan.ge.sh
##                                               bamlist
##                                               ref.fa
##                                               maf_out_prefix
##                                               tumor_purity
##                                               snpeff_genome_version(i.e. 37.64)
##                                               [single_transcript]
##
## OUTPUT:        maf_out_prefix.maf
##                VarScan output in varscan/ directory
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 5 $# $0

# Process input parameters
BAMLIST=$1
REFEREN=$2
OUT_PRE=$3
TPURITY=$4
SNPEFFV=$5
TSINGLE=$6

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
create_dir varscan
SOMATIC_PVAL=0.05
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
        n                                                                       \
        $NGS_ANALYSIS_DIR/modules/somatic/varscan.somatic.vcf.sh                \
          $BAM_N.mpileup                                                        \
          $BAM_T.mpileup                                                        \
          varscan/$SAMPL                                                        \
          $SOMATIC_PVAL                                                         \
          $TPURITY

  # Convert varscan snp output to maf
  $QSUB vcf2maf                                                                 \
        all.q                                                                   \
        1                                                                       \
        5G                                                                      \
        varscan.$SAMPL                                                          \
        n                                                                       \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.varscan.snp.sh             \
          $SAMPL                                                                \
          varscan/$SAMPL.snp.vcf                                                \
          $SNPEFFV

  # Convert varscan indel output to maf
  $QSUB vcf2maf                                                                 \
        all.q                                                                   \
        1                                                                       \
        5G                                                                      \
        varscan.$SAMPL                                                          \
        n                                                                       \
        $NGS_ANALYSIS_DIR/pipelines/ngs.pipe.vcf2maf.varscan.indel.sh           \
          $SAMPL                                                                \
          varscan/$SAMPL.indel.vcf                                              \
          $SNPEFFV

done

# If select single transcript per gene
if [ ! -z $TSINGLE ]; then
  # Select transcript per gene
  t2l=$NGS_ANALYSIS_DIR/resources/ensembl.GRCh37.67.transcripts.bed.lengths.pkl
  $QSUB select.single.transcript                                                \
        all.q                                                                   \
	1                                                                       \
	1G                                                                      \
	vcf2maf                                                                 \
	n                                                                       \
	$NGS_ANALYSIS_DIR/modules/util/python_ngs.sh                            \
          vcf_snpeff_count_transcript_effects.py                                \
            -l $t2l                                                             \
            -o $OUT_PRE.tcount                                                   \
            varscan/*snpeff.vcf

  # Generate maf for each sample based on the selected transcripts
  for bamfiles in `sed 's/\t/:/g' $BAMLIST`; do
    SAMPL=`echo $bamfiles | cut -f1 -d':'`
    VCF_SNP_ANNOTFILE=`ls varscan/$SAMPL.snp.somatic.*snpeff.vcf`
    VCF_INDEL_ANNOTFILE=`ls varscan/$SAMPL.indel.somatic.*snpeff.vcf`
    for file in $VCF_SNP_ANNOTFILE $VCF_INDEL_ANNOTFILE; do
      $QSUB vcf2maf                                                             \
            all.q                                                               \
            1                                                                   \
            4G                                                                  \
            select.single.transcript                                            \
            n                                                                   \
            $NGS_ANALYSIS_DIR/modules/util/python_ngs.sh vcf2maf.py             \
              $file                                                             \
              $SAMPL                                                            \
              $GENE2ENTREZ                                                      \
              -s $OUT_PRE.tcount.g2t.pkl                                         \
              -t varscan                                                        \
              -o $file.maf
    done
  done
fi


exit




######################################################################################
# Merge all mafs
$QSUB merge.maf                                                                 \
      all.q                                                                     \
      1                                                                         \
      1G                                                                        \
      vcf2maf                                                                   \
      n                                                                         \
      $NGS_ANALYSIS_DIR/modules/somatic/merge_maf.sh $OUT_PRE varscan/*maf


# Generate summaries about the maf file
grep -v "3'Flank" $OUT_PRE.maf | grep -v "5'Flank" > $OUT_PRE.noflank.maf
python_ngs.sh maf_summaries.py $OUT_PRE.noflank.maf -t pos_simple   -o $OUT_PRE.noflank.maf.summary.pos.simple
python_ngs.sh maf_summaries.py $OUT_PRE.noflank.maf -t pos_detailed -o $OUT_PRE.noflank.maf.summary.pos.detailed
python_ngs.sh maf_summaries.py $OUT_PRE.noflank.maf -t gene         -o $OUT_PRE.noflank.maf.summary.gene