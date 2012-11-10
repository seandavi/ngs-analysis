#!/usr/bin/env python

import re
import sys
from collections import namedtuple

class FastqFile(object):
    '''
    Class to handle fastq files
    '''
    def __init__(self, filehandle):
        self.f = filehandle

    def __iter__(self):
        return self

    def next(self):
        record_id = self.f.next().strip('\n')
        record_seq = self.f.next().strip('\n')
        record_info = self.f.next().strip('\n')
        record_qscores = self.f.next().strip('\n')
        return record_id, record_seq, record_info, record_qscores

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
    
class FastqFilePairs(object):
    '''
    Class to handle pairs of fastq files, for paired reads
    '''
    STATUS={'BOTH_FAIL': 0,
            'R1_PASS':   1,
            'R2_PASS':   2,
            'BOTH_PASS': 3}

    def __init__(self, f_R1, f_R2):
        '''
        f_R1 is file handle for read 1
        f_R2 is file handle for read 2
        '''
        self.f1 = FastqFile(f_R1)
        self.f2 = FastqFile(f_R2)

    def __iter__(self):
        return self

    def next(self):
        return self.f1.next(), self.f2.next()

    def generate_length_tests(self, minlen=1):
        '''
        Generates statuses of whether both of the reads passed the minimum length requirement
        '''
        for rec1,rec2 in self:
            len1 = len(rec1[1])
            len2 = len(rec2[1])
            if len1 >= minlen and len2 >= minlen:
                status = FastqFilePairs.STATUS['BOTH_PASS']
            elif len1 <= minlen and len2 <= minlen:
                status = FastqFilePairs.STATUS['BOTH_FAIL']
            elif len1 >= minlen:
                status = FastqFilePairs.STATUS['R1_PASS']
            else:
                status = FastqFilePairs.STATUS['R2_PASS']
            yield status, rec1, rec2
