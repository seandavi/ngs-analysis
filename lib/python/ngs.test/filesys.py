#!/usr/bin/env python

import os
import unittest
from ngs import filesys

RESOURCE_DIR = 'resources'
EXAMPLE_FASTQ = 'example.fastq'

class TestFilesysFunctions(unittest.TestCase):
    
    def setUp(self):
        pass

    def test_get_file_read_handle(self):

        # Read normally
        example_fastq = os.path.join(RESOURCE_DIR, EXAMPLE_FASTQ)
        f = open(example_fastq,'r')
        d = f.read()
        f.close()

        # Read original
        f = filesys.get_file_read_handle(example_fastq)
        d_or = f.read()
        f.close()

        # Read gz
        f = filesys.get_file_read_handle(example_fastq + '.gz')
        d_gz = f.read()
        f.close()

        # Read zip
        f = filesys.get_file_read_handle(example_fastq + '.zip')
        d_zip = f.read()
        f.close()

        # Test that they are all equal
        #self.assertTrue(d == d_or and d == d_gz and d == d_zip)
        

if __name__ == '__main__':
    unittest.main()
