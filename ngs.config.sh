#!/bin/bash
##
## SET UP PROGRAM AND RESOURCE PATHS
##

#=====================================================================================
# Users: Set path to each tool installed on the server

# Programs
export NGS_ANALYSIS_DIR=path/to/ngs-analysis
export PYTHON=path/to/python
export BCL2FASTQ=path/to/CASAVA/bin/configureBclToFastq.pl
export BCL2FASTQ_NUM_THREADS=20
export CUTADAPT=path/to/cutadapt
export SICKLE=path/to/sickle
export BWA=path/to/
export PICARD_PATH=path/to/
export PICARD_MAX_RECORDS_IN_RAM=900000
export GATK=path/to/GenomeAnalysisTK.jar
#export VARSCAN=path/to/
#export SOMATIC_SNIPER=path/to/
#export PLINK=path/to/

# Resources
export REF=path/to/human_g1k_v37.fasta
export UCSC_REFFLAT=path/to/refFlat.txt
export UCSC_DBSNP=path/to/snp132.txt
export DBSNP_VCF=path/to/dbsnp_132.b37.vcf
export MILLS_DEVINE_INDEL_VCF=path/to/Mills_Devine_2hit.indels.b37.sites.vcf
export HAPMAP_VCF=path/to/hapmap_3.3.b37.sites.vcf
export OMNI1000_VCF=path/to/1000G_omni2.5.b37.sites.vcf


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
