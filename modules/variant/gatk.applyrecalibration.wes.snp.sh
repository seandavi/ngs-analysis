#!/bin/bash
##
## DESCRIPTION:   Apply the recalibrated variant quality scores to the vcf file
##
## USAGE:         gatk.applyrecalibration.wes.snp.sh 
##                                                   input.vcf
##                                                   in.tranches
##                                                   in.recal
##                                                   ref.fa
##
## OUTPUT:        input.recal.vcf
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 4 $# $0

# Process input params
VCFIN=$1
TRANC=$2
RECAL=$3
REFER=$4

# Format output
OUTPRE=`filter_ext $VCFIN 1`
OUTVCF=$OUTPRE.recal.vcf
OUTLOG=$OUTVCF.log

# Run tool
$JAVAJAR2G $GATK                                                                                 \
   -T ApplyRecalibration                                                                         \
   -R $REFER                                                                                     \
   -input $VCFIN                                                                                 \
   -recalFile $RECAL                                                                             \
   -tranchesFile $TRANC                                                                          \
   -o $OUTVCF                                                                                    \
   -mode SNP                                                                                     \
   &> $OUTLOG


# Arguments for ApplyRecalibration:
#  -input,--input <input>                                 The raw input variants to be recalibrated
#  -recalFile,--recal_file <recal_file>                   The input recal file used by ApplyRecalibration
#  -tranchesFile,--tranches_file <tranches_file>          The input tranches file describing where to cut the data
#  -o,--out <out>                                         The output filtered and recalibrated VCF file in which each 
#                                                         variant is annotated with its VQSLOD value
#  -ts_filter_level,--ts_filter_level <ts_filter_level>   The truth sensitivity level at which to start filtering
#  -ignoreFilter,--ignore_filter <ignore_filter>          If specified the variant recalibrator will use variants even if 
#                                                         the specified filter name is marked in the input VCF file
#  -mode,--mode <mode>                                    Recalibration mode to employ: 1.) SNP for recalibrating only 
#                                                         SNPs (emitting indels untouched in the output VCF); 2.) INDEL 
#                                                         for indels; and 3.) BOTH for recalibrating both SNPs and indels 
#                                                         simultaneously. (SNP|INDEL|BOTH)
