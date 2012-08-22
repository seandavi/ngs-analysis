#!/usr/bin/env python
description = '''
Given a list of files as a single column list, 
this program tries to figure out how they pair up
to make a normal/tumor pair, assuming pairs exist
within the input.

Output the resulting pairs in the following format:

Columns:
normal_filename
tumor_filename
'''

import argparse
import re
import sys

PATTERNS = (('_N','_T'),
            ('N_','T_'),
            ('_N_','_T_'),
            ('-N','-T'),
            ('N-','T-'),
            ('-N-','-T-'),
            ('.N','.T'),
            ('N.','T.'),
            ('.N.','.T.'))

def check_pattern(pattern, filenames_list):
    '''
    Given a pattern in PATTERNS, check
    if the pattern exists in filenames_list.
    If the pattern causes the filenames to divide
    in half, return True
    Otherwise, return False
    '''
    # Divide up the files
    n_files = []
    t_files = []
    for filename in filenames_list:
        match_n = re.search(pattern[0] ,filename)
        match_t = re.search(pattern[1], filename)
        if match_n and not match_t:
            n_files.append(filename)
        elif not match_n and match_t:
            t_files.append(filename)
    
    # If all the files divided up evenly, then pattern works
    len_n_files = len(n_files)
    len_t_files = len(t_files)

    # All files were divided evenly
    if len_n_files == len_t_files:
        if len_n_files + len_t_files == len(filenames_list):
            sys.stderr.write('Pattern %s divided up the files evenly\n' % str(pattern))
            return n_files, t_files

    # Files were divided unevenly
    elif len_n_files > 0 and len_t_files > 0:
        if len_n_files + len_t_files == len(filenames_list):
            sys.stderr.write('Pattern %s divided up the files unevenly\n' % str(pattern))
            return n_files, t_files
    
    return False

def search_matching_tumorfile(normalfile, tumorfiles, pattern):
    '''
    Given a normal filename, find the matching tumor file
    '''
    nf = normalfile.replace(pattern[0], pattern[1])
    nf = re.sub(r'_[ACGT]{6}_', '_.{4}_', nf)
    nf = re.sub(r'_L.{3}_', '_L..._', nf)
    for tf in tumorfiles:        
        result = re.search(nf, tf)
        if result:
            return tf
    return False

def detect_pairs(samplenames):
    '''
    Figure out the N and T pairs from a list of filenames
    and return the pairs as a list of tuples, i.e.
    [(Sample1_N.bam, Sample1_T.bam),
     (Sample2_N.bam, Sample2_T.bam),
     (Sample3_N.bam, Sample3_T.bam)]
    '''
    
    # Check each pattern in PATTERNS against the filenames
    for pattern in PATTERNS:
        check_result = check_pattern(pattern, samplenames)

        # Files divided up either evenly or unevenly
        if check_result:
            normal_files = sorted(check_result[0])
            tumor_files = sorted(check_result[1])

            # Generate the matching pairs
            matched_pairs = []
            for n_file in normal_files:
                t_file = search_matching_tumorfile(n_file, tumor_files, pattern)
                if t_file:
                    matched_pairs.append((n_file,t_file))
                
            # Check to make sure that the ordered files are matched up
            return matched_pairs

    # None of the patterns worked
    return False

def main():
    # Set up parameter options
    ap = argparse.ArgumentParser(description=description)
    ap.add_argument('input_file',
                    help='Single column list of files',
                    nargs='?',
                    type=argparse.FileType('r'),
                    default=sys.stdin)
    params = ap.parse_args()

    # Read all filenames into a list
    filenames = []
    for line in params.input_file:
        fname = line.strip().split()[0]
        filenames.append(fname)
    params.input_file.close()

    # Detect sample ids from filenames and map them
    sampleid2filename = {}
    for filename in filenames:
        # Look for index in the filename
        match = re.search(r'(.+)[ACTG]{6}', filename)
        if match:
            sampleid = match.group(1)
            sampleid2filename[sampleid] = filename
            continue
        # Look for lane number in the filename
        match = re.search(r'(.+)L\d{3}', filename)
        if match:
            sampleid = match.group(1)
            sampleid2filename[sampleid] = filename
            continue

        # No match indicates index and lane number are not present in the filename
        sampleid2filename[filename] = filename

    # Detect the paired filenames
    pairs = detect_pairs(sorted(sampleid2filename.keys()))

    # Could not detect pairs
    if not pairs:
        sys.stderr.write('Could not detect paired files.\n')
        sys.exit(1)

    # Output to standard output
    for pair in pairs:
        normal_file = sampleid2filename[pair[0]]
        tumor_file = sampleid2filename[pair[1]]
        sys.stdout.write('%s\t%s\n' % (normal_file, tumor_file))


if __name__ == '__main__':
    main()
