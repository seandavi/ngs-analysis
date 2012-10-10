#!/usr/bin/env python

import os
import sys
import unittest
from ngs import fastq


class TestMafFileFunctions(unittest.TestCase):
    
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

if __name__ == '__main__':
    unittest.main()
