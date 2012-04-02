#!/usr/bin/env python

import io
import xml.dom.minidom
from ngs import filesys,seq

class FastqStats(object):
    
    XML_FASTQ = 'fastq'
    XML_STATS = 'stat'
    XML_READCOUNT = 'readcount'
    XML_BASECOUNT = 'basecount'
    XML_READ_LENGTH_HIST = 'read_length_hist'
    XML_READ_LENGTH_BIN = 'length_bin'
    XML_READ_LENGTH_BIN_LENGTH = 'read_length'
    XML_READ_LENGTH_BIN_COUNT = 'count'

    fastqfilename = None
    basecount = None
    readcount = None
    length_hist = None

    def __init__(self, fastqfilename, basecount=None, readcount=None, length_hist=None):
        '''
        Constructor with optional input params
        '''
        self.fastqfilename = fastqfilename
        self.basecount = basecount
        self.readcount = readcount
        self.length_hist = length_hist

    def set_seqstats(self):
        '''
        Read in the file and generate stats about the sequences.
        '''
        fin = filesys.get_file_read_handle(self.fastqfilename)
        self.basecount = 0
        self.readcount = 0
        self.length_hist = {}
        for i,line in enumerate(fin):
            # If sequence line (line 2 of 4)
            if i % 4 == 1:
                read_len = len(line.strip())
                self.basecount += read_len
                self.readcount += 1
                # Update histogram
                if read_len in self.length_hist:
                    self.length_hist[read_len] += 1
                else:
                    self.length_hist[read_len] = 1
        # Close filehandle
        fin.close()

    def get_seqstats(self):
        '''
        Lazy getter for sequence statistics
        '''
        if self.basecount is None or self.readcount is None or self.length_hist is None:
            self.set_seqstats()
        return self.basecount, self.readcount, self.length_hist
        
    def seqstats2txt(self):
        '''
        Generate human-readable text file containing sequence statistics
        '''
        basecount, readcount, length_hist = self.get_seqstats()
        
        

    def seqstats2xml(self):
        '''
        Generate xml from sequence statistics
        '''
        basecount, readcount, length_hist = self.get_seqstats()

        doc = xml.dom.minidom.Document()
        
        # <fastq>
        element_fastq = doc.createElement(self.XML_FASTQ)
        doc.appendChild(element_fastq)

        # <stats>
        element_stats = doc.createElement(self.XML_STATS)
        element_fastq.appendChild(element_stats)

        # <readcount>
        element_readcount = doc.createElement(self.XML_READCOUNT)
        element_readcount.appendChild(doc.createTextNode(str(readcount)))
        element_stats.appendChild(element_readcount)

        # <basecount>
        element_basecount = doc.createElement(self.XML_BASECOUNT)
        element_basecount.appendChild(doc.createTextNode(str(basecount)))
        element_stats.appendChild(element_basecount)

        # <read_length_hist>
        element_hist = doc.createElement(self.XML_READ_LENGTH_HIST)
        for length,count in length_hist.iteritems():
            # <length_bin>
            element_length_bin = doc.createElement(self.XML_READ_LENGTH_BIN)
            # <read_length>
            element_length_bin_length = doc.createElement(self.XML_READ_LENGTH_BIN_LENGTH)
            element_length_bin_length.appendChild(doc.createTextNode(str(length)))
            element_length_bin.appendChild(element_length_bin_length)
            # <count>
            element_length_bin_count = doc.createElement(self.XML_READ_LENGTH_BIN_COUNT)
            element_length_bin_count.appendChild(doc.createTextNode(str(count)))
            element_length_bin.appendChild(element_length_bin_count)
            # Append to node
            element_hist.appendChild(element_length_bin)
        element_stats.appendChild(element_hist)
        return doc.toxml()
        
    def xml2seqstats(self, xmlstring):
        '''
        Parse xmlstring and extract fastq stats
        '''
        # Start parsing xml
        dom = xml.dom.minidom.parseString(xmlstring)
        element_fastq = dom.getElementsByTagName(self.XML_FASTQ)[0]
        element_stats = element_fastq.getElementsByTagName(self.XML_STATS)[0]

        # Readcount
        element_readcount = element_stats.getElementsByTagName(self.XML_READCOUNT)[0]
        readcount = element_readcount.childNodes[0].data

        # Basecount
        element_basecount = element_stats.getElementsByTagName(self.XML_BASECOUNT)[0]
        basecount = element_basecount.childNodes[0].data

        # Length histogram
        length_hist = {}
        element_hist = element_stats.getElementsByTagName(self.XML_READ_LENGTH_HIST)[0]
        for element_length_bin in element_hist.getElementsByTagName(self.XML_READ_LENGTH_BIN):
            # Read length
            element_read_length = element_length_bin.getElementsByTagName(self.XML_READ_LENGTH_BIN_LENGTH)[0]
            read_length = element_read_length.childNodes[0].data
            # Counts
            element_count = element_length_bin.getElementsByTagName(self.XML_READ_LENGTH_BIN_COUNT)[0]
            counts = element_count.childNodes[0].data
            length_hist[int(read_length)] = int(counts)

        return int(readcount), int(basecount), length_hist

