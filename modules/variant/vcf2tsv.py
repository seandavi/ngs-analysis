#!/usr/bin/env python
description = '''
Read in a vcf file, parse and output the data in tsv format.
'''

import argparse
import sys
from ngs import vcf

def parse_vcf(vcf_in, fout):
    '''
    Read through the vcf file, and parse it.
    Output results in tsv format
    '''
    with vcf.VcfFile(vcf_in, 'r') as vcffile:

        # Skip to the variants section of the vcf file
        vcffile.jump2variants()
        sample_names = vcffile.get_sample_names()
        sample_names_gt = [sn + '_gt' for sn in sample_names]
        sample_names_dp = [sn + '_dp' for sn in sample_names]

        # Output header line
        fout.write('%s\n' % '\t'.join(['Chrom',
                                       'Position',
                                       'Ref',
                                       'Alt',
                                       'Type',
                                       'AF',
                                       'NoCall'] +
                                      sample_names_gt +
                                      sample_names_dp))

        # Read in the variant lines
        for line in vcffile:

            # Get parsed variant data
            variant = vcffile.parse_line(line)
            # Record columns
            chrom = variant['CHROM']
            pos = variant['POS']
            ref = variant['REF']
            alt = variant['ALT']

            # Parse the info column
            info_map, info_single = vcffile.parse_info(variant)
            af = info_map['AF']

            # Variant type
            variant_type = 'snp'
            len_ref = len(ref)
            len_alt = len(alt)
            if len_ref > 1 or len_alt > 1:
                if len_ref > len_alt:
                    variant_type = 'del'
                elif len_ref < len_alt:
                    variant_type = 'ins'
                else: # len_ref == len_alt
                    if len_ref == 2:
                        variant_type = 'dnp'
                    elif len_ref == 3:
                        variant_type = 'tnp'
                    else:
                        variant_type = 'onp'

            # Sample genotypes
            samples2field2val = vcffile.parse_samples(variant)
            samples_gts = []
            samples_dps = []
            num_nocall = 0
            for sample in sample_names:
                sample_gt = vcffile.get_sample_gt(variant, sample)
                if sample_gt == 'N/N':
                    num_nocall += 1
                if 'DP' not in samples2field2val[sample]:
                    sample_dp = 'NA'
                else:
                    sample_dp = samples2field2val[sample]['DP']
                samples_gts.append(sample_gt)
                samples_dps.append(sample_dp)

            # Output to standard output
            fout.write('%s\n' % '\t'.join([chrom,
                                           pos,
                                           ref,
                                           alt,
                                           variant_type,
                                           af,
                                           str(num_nocall)] +
                                          samples_gts +
                                          samples_dps))

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    type=str)
    ap.add_argument('-o', '--outfile',
                    help='Output result file',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()

    # Generate maf
    parse_vcf(params.vcf_file,
              params.outfile)


if __name__ == '__main__':
    main()
