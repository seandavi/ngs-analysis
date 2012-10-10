#!/usr/bin/env python

import re
import sys
from collections import namedtuple

class FastqFile(file):
    '''
    Extension of the python File class to handle fastq formatted files
    '''
    pass

class IlluminaFastqFile(FastqFile):
    '''
    Extension of the FastqFile class to handle illumina fastq formatted files
    '''
    
    ILLUMINA_FASTQ_RE = r'(.+)_([ACGT]+)_(L\d{3})_(R[12])_(\d{3})\.fastq\.gz'
    ILLUMINA_FASTQ_FILENAME_FIELDS = namedtuple('IlluminaFastqFilename', ['sample',
                                                                          'barcode',
                                                                          'lane',
                                                                          'read',
                                                                          'set'])
    @staticmethod
    def is_illumina(filename):
        '''
        Given a filename, return True if the filename is in the illumina fastq format
        i.e. Samplename_AAAAAA_L00N_R1_00C.fastq.gz
        '''
        if re.search(IlluminaFastqFile.ILLUMINA_FASTQ_RE, filename):
            return True
        return False

    @staticmethod
    def parse_filename(filename):
        '''
        Check that the filename is in illumina fastq filename format, and generate a
        namedtuple object containig the components of the name
        '''
        if not IlluminaFastqFile.is_illumina(filename):
            raise ValueError, "Not illumina fastq file"

        match = re.search(IlluminaFastqFile.ILLUMINA_FASTQ_RE, filename)
        return IlluminaFastqFile.ILLUMINA_FASTQ_FILENAME_FIELDS._make([match.group(1),
                                                                       match.group(2),
                                                                       match.group(3),
                                                                       match.group(4),
                                                                       match.group(5)])
    
