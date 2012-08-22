#!/usr/bin/env python
description = '''
Given a Hiseq sample directory, detect all the paired end fastq file pairs.
Output the file pairs to standard output in the following format:

Columns:
Samplename_AAAAAA_L00N_R1_00C.fastq.gz
Samplename_AAAAAA_L00N_R2_00C.fastq.gz
'''

import argparse
import os
import re
import sys

def list_fastq_files(sampledir):
    '''
    Find all fastq files in the sampledir
    '''
    fastqfiles = []
    for filename in os.listdir(sampledir):
        if re.search(r'.+_[ACGT]+_L\d{3}_R[12]_\d{3}\.fastq\.gz', filename):
            fastqfiles.append(os.path.join(sampledir, filename))
    return fastqfiles

def is_read1(fastq_file):
    '''
    Check if fastq_file is read 1
    '''
    if re.search(r'.+_[ACGT]+_L\d{3}_R[1]_\d{3}\.fastq\.gz', fastq_file):
        return True
    return False

def detect_pe_file_pairs(fastq_files):
    '''
    Given a list of fastq files, detect all paired end file pairs and output
    them as a list of tuples, where each tuple is (read1, read2)
    i.e. [(r1,r2),(r1,r2),...,(r1,r2)]
    '''
    file_pairs = []
    i = 0
    num_files = len(fastq_files)
    while True:
        fastqfile = fastq_files.pop(0)
        i += 1

        # If file is read 1, extract read 2 and insert into file_pairs
        if is_read1(fastqfile):
            file_r1 = fastqfile
            file_r2 = fastqfile.replace('_R1_', '_R2_')            
            if file_r2 in fastq_files:
                fastq_files.remove(file_r2)
                file_pairs.append((file_r1, file_r2))
            else:
                fastq_files.insert(-1, fastqfile)
        # File is read 2, so extract read 1 and insert into file_pairs
        else:
            file_r1 = fastqfile.replace('_R2_', '_R1_')
            file_r2 = fastqfile
            if file_r1 in fastq_files:
                fastq_files.remove(file_r1)
                file_pairs.append((file_r1, file_r2))
            else:
                fastq_files.insert(-1, fastqfile)

        # If list is empty, break out of loop
        if len(fastq_files) == 0:
            break
        # If the number of iterations has reached the size of the list, break out of loop
        if i >= num_files:
            break

    return file_pairs

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('sample_dir',
                    help='Illumina Hiseq basecalled sample directory containing fastq files',
                    type=str)
    params = ap.parse_args()

    # Check to see that the directory exists
    if not os.path.isdir(params.sample_dir):
        sys.stderr.write('Directory \'%s\' does not exist.  Exiting.\n\n' % params.sample_dir)
        sys.exit(1)

    # Find all fastq files in the samples directory
    fastq_files = list_fastq_files(params.sample_dir)

    # If no fastq files are present, exit with error
    if not fastq_files:
        sys.stderr.write('Zero fastq files detected in sample directory \'%s\'.  Exiting.\n\n' % params.sample_dir)
        sys.exit(1)

    # Detect pe file pairs
    file_pairs = detect_pe_file_pairs(fastq_files)

    # If no pairs detected, exit with error
    if not file_pairs:
        sys.stderr.write('Zero PE fastq file pairs detected in sample directory \'%s\'. Exiting.\n\n' % params.sample_dir)
        sys.exit(1)

    # Sort results
    file_pairs = sorted(file_pairs, key=lambda t: t[0])

    # Write pairs to standard output
    for pair in file_pairs:
        sys.stdout.write('%s\t%s\n' % pair)
    

if __name__ == '__main__':
    main()
