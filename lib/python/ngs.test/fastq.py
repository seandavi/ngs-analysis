#!/usr/bin/env python

import contextlib
import os
import sys
import unittest
from ngs import fastq

resource_dir = 'resources'
example_fastqfile_R1 = 'example.R1.fastq'
example_fastqfile_R2 = 'example.R2.fastq'

class TestFastqFileFunctions(unittest.TestCase):

    def setUp(self):
        self.fastqfile1 = os.path.join(resource_dir, example_fastqfile_R1)
        self.fastqfile2 = os.path.join(resource_dir, example_fastqfile_R2)

    def test_next(self):
        f = open(self.fastqfile1, 'r')
        with f:
            fastqfile = fastq.FastqFile(f)
            (record_id,
             record_seq,
             record_info,
             record_qscore) = fastqfile.next()
            self.assertEqual(record_id, '@SEQ_ID1')
            self.assertEqual(record_qscore, '!\'\'*((((**')
            record = fastqfile.next()
            self.assertEqual(record[1], 'GGGGGTTTTT')
            record = fastqfile.next()
            self.assertEqual(record[1], 'AAAAAGGGGG')

    def test_lengthfilter(self):
        f = open(self.fastqfile2,'r')
        with f:
            fastqfile = fastq.FastqFile(f)
            sequences = []
            for record in fastqfile.generate_length_filtered_records(1):
                sequences.append(record[1])
            
        self.assertEqual(len(sequences), 2)
        self.assertEqual(sequences[0], 'AAAAACCCCC')
        self.assertEqual(sequences[1], 'AAAAAGGGGG')

class TestIlluminaFastqFileFunctions(unittest.TestCase):
    
    def setUp(self):
        self.fastqfile = 'Sample_name_ACAGTG_L003_R1_001.fastq.gz'

    def test_is_illumina(self):
        self.assertTrue(fastq.IlluminaFastqFile.is_illumina(self.fastqfile))
        self.assertFalse(fastq.IlluminaFastqFile.is_illumina('hello'))

    def test_parse_filename(self):
        filename_fields  = fastq.IlluminaFastqFile.parse_filename(self.fastqfile)
        self.assertEqual(filename_fields.sample, 'Sample_name')
        self.assertEqual(filename_fields.barcode, 'ACAGTG')
        self.assertEqual(filename_fields.lane, 'L003')
        self.assertEqual(filename_fields.read, 'R1')
        self.assertEqual(filename_fields.set, '001')

class TestFastqFilePairsFunctions(unittest.TestCase):
    def setUp(self):
        self.fastqfile1 = os.path.join(resource_dir, example_fastqfile_R1)
        self.fastqfile2 = os.path.join(resource_dir, example_fastqfile_R2)

    def test_generate_length_tests(self):
        f1 = open(self.fastqfile1, 'r')
        f2 = open(self.fastqfile2, 'r')
        with contextlib.nested(f1, f2):
            fastqpairs = fastq.FastqFilePairs(f1, f2)
            testgen = fastqpairs.generate_length_tests()

            # First record
            status, rec1, rec2 = testgen.next()
            self.assertEqual(rec1[0], '@SEQ_ID1')
            self.assertEqual(status, 3)

            # Second record
            status, rec1, rec2 = testgen.next()
            self.assertEqual(status, 1)

        f1 = open(self.fastqfile1, 'r')
        f2 = open(self.fastqfile2, 'r')
        test_results = []
        with contextlib.nested(f1, f2):
            fastqpairs = fastq.FastqFilePairs(f1, f2)
            for status, rec1, rec2 in fastqpairs.generate_length_tests(1):
                test_results.append(status)
        self.assertEqual(test_results, [3,1,3])

        f1 = open(self.fastqfile1, 'r')
        f2 = open(self.fastqfile2, 'r')
        test_results = []
        with contextlib.nested(f1, f2):
            fastqpairs = fastq.FastqFilePairs(f1, f2)
            for status, rec1, rec2 in fastqpairs.generate_length_tests(11):
                test_results.append(status)
        self.assertEqual(test_results, [0,0,0])

if __name__ == '__main__':
    unittest.main()
