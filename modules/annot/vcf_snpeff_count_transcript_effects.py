#!/usr/bin/env python
description = '''
Read in vcf file(s) outputted by SNPEff.
Count transcript effects.
Also generate a list of effects2impact mapping
'''

import argparse
from ngs import util
from ngs import vcf

def generate_counts(vcf_filenames, outprefix, highest_priority=False):
    '''
    Read through a vcf file outputted by snpeff and count the transcription effects for each variant.
    If highest_priority is set to true, then only count the highest priority transcript effect
    per variant.
    '''
    # Generate SnpEffVcfFiles objects
    vcffiles = vcf.SnpEffVcfFiles([vcf.SnpeEffVcfFile(fn) for fn in vcf_filenames])
    
    # Count up all the transcript effects
    g2t2e2c, effects2impact = vcffiles.count_transcript_effects_all(highest_priority=highest_priority)
    
    # Create output files
    g2t2e2c_outfile = outprefix + '.counts'
    effects2impact_outfile = outprefix + '.eff2imp'

    # Output to files
    with open(g2t2e2c_outfile, 'w') as f:
        f.write(util.dict2xml(g2t2e2c))

    with open(effects2impact_outfile, 'w') as f:
        f.write(util.dict2xml(effects2impact))
    

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_files',
                    help='Vcf files outputted by SNPEff',
                    nargs='+',
                    type=str)
    ap.add_argument('-e', '--highest-priority-effect',
                    help='If this flag is set, the highest-priority effect transcript will be selected from each variant annotation',
                    action='store_true')
    ap.add_argument('-o', '--outprefix',
                    help='Output prefix',
                    default='transcript_effects')
    params = ap.parse_args()

    # Generate counts
    generate_counts(params.vcf_files, params.outprefix, highest_priority=params.highest_priority_effect)


if __name__ == '__main__':
    main()
