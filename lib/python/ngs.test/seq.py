#!/usr/bin/env python

import os
import sys
import unittest
from ngs import seq

RESOURCE_DIR = 'resources'
EXAMPLE_FASTQ = os.path.join(RESOURCE_DIR,'example.fastq')
EXAMPLE_FASTQ_SEQSTAT_XML = os.path.join(RESOURCE_DIR, 'example.fastq.seqstat.xml')
EXAMPLE_FASTQ_SEQSTAT_TXT = os.path.join(RESOURCE_DIR, 'example.fastq.seqstat.txt')

class TestFastqStats(unittest.TestCase):
    
    def setUp(self):
        self.fastqstats_obj = seq.FastqStats(EXAMPLE_FASTQ)
        self.readcount, self.basecount, self.length_hist = self.fastqstats_obj.get_seqstats()

    def test_get_seqstats(self):
        self.assertEqual(self.readcount, 3)
        self.assertEqual(self.basecount, 35)
        self.assertEqual(self.length_hist[10], 2)
        self.assertEqual(self.length_hist[15], 1)
        self.assertEqual(len(self.length_hist), 2)

    def test_seqstats2txt(self):
        # Generate seqstat txt from fastqfile
        seqstat_txt = self.fastqstats_obj.seqstats2txt()

        # Load seqstat txt from file that's already been generated
        f = open(EXAMPLE_FASTQ_SEQSTAT_TXT, 'r')
        seqstat_txt_from_file = f.read()
        f.close()
        
        # Compare them to make sure they are equal
        self.assertEqual(seqstat_txt, seqstat_txt_from_file)

    def test_seqstats2xml(self):
        # Generate xml for the seqstats
        seqstat_xml = self.fastqstats_obj.seqstats2xml()
        # Output xml to file
        f = open(EXAMPLE_FASTQ_SEQSTAT_XML, 'w')
        f.write(seqstat_xml)
        f.close()

        # Read xml file
        f = open(EXAMPLE_FASTQ_SEQSTAT_XML, 'r')
        seqstat_xml = f.read()
        f.close()

        # Extract stats from xml
        rc, bc, lh = self.fastqstats_obj.xml2seqstats(seqstat_xml)

        # Run comparisons
        self.assertEqual(rc, self.readcount)
        self.assertEqual(bc, self.basecount)
        self.assertEqual(lh[10], self.length_hist[10])
        self.assertEqual(lh[15], self.length_hist[15])
        self.assertEqual(len(lh), len(self.length_hist))


if __name__ == '__main__':
    unittest.main()
