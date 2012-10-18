#!/bin/bash
##
## DESCRIPTION:   Variant call on bam file(s) using grid engine, and using B37 resource files
##
## USAGE:         gatk.unifiedgenotyper.wes.ge.b37.sh 
##                                                    out_vcf
##                                                    target_region
##                                                    num_threads
##                                                    input1.bam [input2.bam [...]]
##
## OUTPUT:        out_prefix.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 4 $# $0

# Process input params
PARAMS=($@)
NUM_PARAMS=${#PARAMS[@]}
OUTVCF=${PARAMS[0]}
TARGET=${PARAMS[1]}
THREAD=${PARAMS[2]}
NUM_BAMFILES=$(($NUM_PARAMS - 3))
BAMFILES=${PARAMS[@]:3:$NUM_BAMFILES}

# Format output filenames
OUTLOG=$OUTVCF.log

# Run variant call
QSUB=$NGS_ANALYSIS_DIR/modules/util/qsub_wrapper.sh
GATK_UG=$NGS_ANALYSIS_DIR/modules/variant/gatk.unifiedgenotyper.wes.sh
$QSUB unifiedgeno.$$                 \
      all.q                          \
      $THREAD                        \
      none                           \
      n                              \
      $GATK_UG $TARGET               \
               $B3x_REF              \
	       $B3x_DBSNP_VCF        \
	       $OUTVCF               \
               $THREAD               \
               $BAMFILES

