#!/usr/bin/env python

import gzip
import os
import sys
import zipfile

def get_file_read_handle(filename):
    '''
    Given a filename, check the extension
    and return the proper file read handle
    '''
    file_ext = os.path.splitext(filename)[1]
    try:
        if file_ext == 'zip' and zipfile.is_zipfile(filename):
            f = zipfile.ZipFile(filename, 'r')
        elif file_ext == 'gz':
            f = gzip.GzipFile(filename, 'r')
        else:
            f = open(filename, 'r')
        return f
    except IOError:
        return False

