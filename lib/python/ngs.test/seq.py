#!/usr/bin/env python

import os
import unittest
from ngs import seq

RESOURCE_DIR = 'resources'
EXAMPLE_FASTQ = 'example.fastq'
EXAMPLE_FASTQ_SEQSTAT_XML = 'example.fastq.seqstat.xml'

class TestSeqFunctions(unittest.TestCase):
    
    def setUp(self):
        f = open(os.path.join(RESOURCE_DIR, EXAMPLE_FASTQ), 'r')
        self.fastqstats_obj = seq.FastqStats()
        self.readcount, self.basecount, self.length_hist = self.fastqstats_obj.get_seqstats(f)        

    def test_fastq_seqstats(self):
        self.assertEqual(self.readcount, 3)
        self.assertEqual(self.basecount, 35)
        self.assertEqual(self.length_hist[10], 2)
        self.assertEqual(self.length_hist[15], 1)
        self.assertEqual(len(self.length_hist), 2)

    def test_seqstats2xml(self):
        # Generate xml for the seqstats
        seqstat_xml = self.fastqstats_obj.seqstats2xml(self.readcount, self.basecount, self.length_hist)
        # Output xml to file
        seqstat_xml_file = os.path.join(RESOURCE_DIR, EXAMPLE_FASTQ_SEQSTAT_XML)
        f = open(seqstat_xml_file, 'w')
        f.write(seqstat_xml)
        f.close()

        # Read xml file
        f = open(seqstat_xml_file, 'r')
        seqstat_xml = f.read()
        f.close()
        rc, bc, lh = self.fastqstats_obj.xml2seqstats(seqstat_xml)
        self.assertEqual(rc, self.readcount)
        self.assertEqual(bc, self.basecount)
        self.assertEqual(lh[10], self.length_hist[10])
        self.assertEqual(lh[15], self.length_hist[15])
        self.assertEqual(len(lh), len(self.length_hist))


if __name__ == '__main__':
    unittest.main()
