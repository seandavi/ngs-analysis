#!/bin/bash

###################################################################################
# SET UP WORKSPACE

# Set environment variables
export NGS_ANALYSIS_DIR=`pwd`
export PATH=$PATH:$NGS_ANALYSIS_DIR/scripts
export PYTHONPATH=$PYTHONPATH:$NGS_ANALYSIS_DIR/lib/python

# Import bash function library
source $NGS_ANALYSIS_DIR/lib/bash/bash_fnc.sh

# Create additional workspace directories
create_dir data
create_dir tmp
create_dir reports

###################################################################################
# EXPERIMENT RUN INFORMATION
export SAMPLESHEET=path/to/SampleSheet.csv
export READLENGTH=101
export PAIRED=true # [true|false]

###################################################################################
# PROGRAMS
export PYTHON=path/to/python
export CUTADAPT=path/to/cutadapt
#export SICKLE=path/to/
#export BWA=path/to/
#export PICARD_PATH=path/to/
export GATK=path/to/GenomeAnalysisTK.jar
#export VARSCAN=path/to/
#export SOMATIC_SNIPER=path/to/
#export PLINK=path/to/

###################################################################################
# RESOURCES
export REF=path/to/human_g1k_v37.fasta
export UCSC_REFFLAT=path/to/refFlat.txt
export UCSC_DBSNP=path/to/snp132.txt
export DBSNP_VCF=path/to/dbsnp_132.b37.vcf
export MILLS_DEVINE_INDEL_VCF=path/to/Mills_Devine_2hit.indels.b37.sites.vcf
export HAPMAP_VCF=path/to/hapmap_3.3.b37.sites.vcf
export OMNI1000_VCF=path/to/1000G_omni2.5.b37.sites.vcf





