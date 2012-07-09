#!/bin/bash
##
## SET UP PROGRAM AND RESOURCE PATHS
##

#=====================================================================================
# Users: Set path to each tool installed on the server

# Programs
export NGS_ANALYSIS_CONFIG=${NGS_ANALYSIS_CONFIG:=path/to/ngs.config.sh}  # Set this variable in .bashrc or .bash_profile
export NGS_ANALYSIS_DIR=${NGS_ANALYSIS_DIR:=path/to/ngs-analysis}         # MUST set this variable
export PYTHON=path/to/python
export BCL2FASTQ=path/to/CASAVA/bin/configureBclToFastq.pl
export BCL2FASTQ_NUM_THREADS=20
export CUTADAPT=path/to/cutadapt
export SICKLE=path/to/sickle
export READLENGTH_MIN=20
export QUAL_THRESH=20
export BWA=path/to/bwa
export BWA_ALN_THREAD=2
export BWA_ALN_SEEDLEN=32
export BWA_ALN_MAXSEEDDIFF=2
export SAMTOOLS=path/to/samtools
export PICARD_PATH=path/to/picardtools_directory
export PICARD_MAX_RECORDS_IN_RAM=900000
export GATK=path/to/GenomeAnalysisTK.jar
export GATK_NUM_THREADS=2
export GATK_ANALYZECOVARIATES=path/to/AnalyzeCovariates.jar
export VARSCAN=path/to/VarScan.jar
export SOMATIC_SNIPER=path/to/bam-somaticsniper
export PLINK=path/to/plink

# Resources
export REF=path/to/human_g1k_v37.fasta
export UCSC_REFFLAT=path/to/refFlat.txt
export UCSC_DBSNP=path/to/snp132.txt
export DBSNP_VCF=path/to/dbsnp_132.b37.vcf
export MILLS_DEVINE_INDEL_VCF=path/to/Mills_Devine_2hit.indels.b37.sites.vcf
export INDEL_1000G_PHASE1_VCF=path/to/1000G_phase1.indels.b37.vcf
export HAPMAP_VCF=path/to/hapmap_3.3.b37.sites.vcf
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
export PYTHONPATH=$PYTHONPATH:$NGS_ANALYSIS_DIR/lib/python
export JAVAMEM=-Xmx6g
export JAVATMPDIR=-Djava.io.tmpdir=$PWD
export JAVAJAR='java '$JAVAMEM' '$JAVATMPDIR' -jar'
