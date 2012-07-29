#!/bin/bash
##
## Set up programs and resources' paths
##

#=====================================================================================
# Users: Set path to each tool installed on the server

# Programs
export PYTHON=path/to/python
export BCL2FASTQ=path/to/CASAVA/bin/configureBclToFastq.pl
export CUTADAPT=path/to/cutadapt
export SICKLE=path/to/sickle
export BWA=path/to/bwa
export SAMTOOLS=path/to/samtools
export PICARD_PATH=path/to/picardtools_directory
export GATK=path/to/GenomeAnalysisTK.jar
export GATK_ANALYZECOVARIATES=path/to/AnalyzeCovariates.jar
export VARSCAN=path/to/VarScan.jar
export SOMATIC_SNIPER=path/to/bam-somaticsniper
export SNPEFF=path/to/snpEff.jar
export SNPEFF_CONFIG=path/to/snpEff.config
export VEP=path/to/variant_effect_predictor.pl
export BEDTOOLS_PATH=path/to/bedtools_dir
export FASTQC=path/to/fastqc
export MUSIC=path/to/music

# Resources
export REF=path/to/human_g1k_v37.fasta
export UCSC_REFFLAT=path/to/refFlat.txt
export UCSC_DBSNP=path/to/snp135.txt
export DBSNP_VCF=path/to/dbsnp_135.b37.vcf
export MILLS_DEVINE_INDEL_VCF=path/to/Mills_Devine_2hit.indels.b37.vcf
export MILLS_DEVINE_INDEL_SITES_VCF=path/to/Mills_Devine_2hit.indels.b37.sites.vcf
export INDEL_1000G_PHASE1_VCF=path/to/1000G_phase1.indels.b37.vcf
export HAPMAP_VCF=path/to/hapmap_3.3.b37.vcf
export HAPMAP_SITES_VCF=path/to/hapmap_3.3.b37.sites.vcf
export OMNI1000_VCF=path/to/1000G_omni2.5.b37.sites.vcf
export SURESELECT_BED=path/to/SureSelect_All_Exon_50mb_with_annotation_hg19_bed
export SURESELECT_INTERVAL=path/to/SureSelect_All_Exon_50mb_with_annotation_hg19_bed.exceptChrUn.intervals

#=====================================================================================
# Developers only

# NGS Analysis Pipeline Framework Tools
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/align
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/annot
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/seq
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/somatic
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/util
export PATH=$PATH:$NGS_ANALYSIS_DIR/modules/variant
export JAVAJAR8G='java -Xmx8g -Djava.io.tmpdir='$PWD' -jar'
export JAVAJAR16G='java -Xmx16g -Djava.io.tmpdir='$PWD' -jar'
export JAVAJAR32G='java -Xmx32g -Djava.io.tmpdir='$PWD' -jar'
export JAVAJAR64G='java -Xmx64g -Djava.io.tmpdir='$PWD' -jar'
export JAVAJAR128G='java -Xmx128g -Djava.io.tmpdir='$PWD' -jar'
export JAVAJAR256G='java -Xmx256g -Djava.io.tmpdir='$PWD' -jar'