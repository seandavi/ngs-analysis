#!/usr/bin/env python
description = '''
Read in a vcf file, and annotate the variants using oncotator web service
'''

import argparse
import sys
import time
import urllib2
from ngs import vcf

ONCOTATOR_MUTATION_URL='http://www.broadinstitute.org/oncotator/mutation/%s_%s_%s_%s_%s'
ONCOTATOR_WAIT_TIME = 2 # seconds
ONCOTATOR_MAX_TRIES = 10
ONCOTATOR_RETRY_WAIT = 5

def oncotator_request(chrom, pos_start, pos_end, ref, alt, num_tries=0):
    '''
    Make request to oncotator web server
    '''
    try:
        annot_data = urllib2.urlopen(ONCOTATOR_MUTATION_URL % (chrom, pos_start, pos_end, ref, alt)).read()
        time.sleep(ONCOTATOR_WAIT_TIME)
    except urllib2.HTTPError, e:
        if num_tries >= ONCOTATOR_MAX_TRIES:
            sys.stderr.write("HTTP error: %d\n" % e.code)
            sys.stderr.write('Reached maximum number of tries (%i)\n' % ONCOTATOR_MAX_TRIES)
            sys.stderr.write('Exiting\n')
            sys.exit(1)

        # Wait a few seconds and try again
        time.sleep(ONCOTATOR_RETRY_WAIT)
        return oncotator_request(chrom, pos_start, pos_end, ref, alt, num_tries + 1)
        
    except urllib2.URLError, e:
        sys.stderr.write("Network error: %s\n" % e.reason.args[1])
        sys.stderr.write('Exiting\n')
        sys.exit(1)
        
    return annot_data

def vcf_annotate_variants(vcfin, fout):
    '''
    Read through the variants in vcf file and annotate using oncotator
    '''
    # Skip to the variants section of the vcf file
    vcfin.jump2variants()
    
    # Read in the variant lines
    for line in vcfin:

        # Get parsed variant data
        variant = vcfin.parse_line(line)
        # Record columns
        chrom = variant['CHROM'].replace('chr', '')
        pos_start = variant['POS']
        ref = variant['REF']
        alt = variant['ALT']
        len_ref = len(ref)
        pos_end = str(int(pos_start) + len_ref - 1)

        # Make the web service request to oncotator server
        annot_data = oncotator_request(chrom, pos_start, pos_end, ref, alt)
        fout.write('%s\n' % annot_data)

def main():
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('vcf_file',
                    help='Input vcf file',
                    nargs='?',
                    type=vcf.VcfFile,
                    default=sys.stdin)
    ap.add_argument('-t', '--filetype',
                    help='Input file type (default vcf)',
                    choices=['vcf','maf'],
                    default='vcf')
    ap.add_argument('-o', '--outfile',
                    help='Output result file',
                    type=argparse.FileType('w'),
                    default=sys.stdout)
    params = ap.parse_args()

    # Generate annotations
    with params.vcf_file as vcfin:
        if params.filetype == 'vcf':
            vcf_annotate_variants(vcfin, params.outfile)


if __name__ == '__main__':
    main()
