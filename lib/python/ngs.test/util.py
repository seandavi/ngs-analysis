#!/usr/bin/env python

import sys
import unittest
from ngs import util

class TestUtilFunctions(unittest.TestCase):
    
    def setUp(self):
        pass

    def test_prepend_value_type(self):
        self.assertEqual(util.prepend_value_type(1), '__int1')
        self.assertEqual(util.prepend_value_type('1'), '__num1')
        self.assertEqual(util.prepend_value_type('hello'), 'hello')

    def test_remove_value_type_and_convert(self):
        self.assertEqual(util.remove_value_type_and_convert('__int4'), 4)
        self.assertEqual(util.remove_value_type_and_convert('__num10'), '10')
        self.assertEqual(util.remove_value_type_and_convert('foo'), 'foo')
        self.assertEqual(util.remove_value_type_and_convert('10'), '10')

    def test_dict2xml_and_xml2dict(self):
        d = {}
        generated_xml = util.dict2xml(d, 'foo', pretty=False)
        self.assertEqual(generated_xml, '<?xml version="1.0" ?><foo/>')
        self.assertEqual(d, util.xml2dict(generated_xml))
        
        d = {'a': 1,
             'b': 2,
             'c': 3,}
        generated_xml = util.dict2xml(d, 'foobar', pretty=False)
        desired_output = '<?xml version="1.0" ?><foobar><a>__int1</a><b>__int2</b><c>__int3</c></foobar>'
        generated_d = util.xml2dict(generated_xml)
        self.assertEqual(generated_xml, desired_output)
        self.assertEqual(len(generated_d), 3)
        self.assertEqual(generated_d, d)

        d = {'a': {'aa': 1}}
        desired_output = '<?xml version="1.0" ?><foo><a><aa>__int1</aa></a></foo>'
        generated_xml = util.dict2xml(d, 'foo', pretty=False)
        generated_d = util.xml2dict(generated_xml)
        self.assertEqual(generated_xml, desired_output)
        self.assertEqual(generated_d, d)


        d = {'a': {'11': 1,
                   12: 1,}}
        desired_output = '<?xml version="1.0" ?><foo><a><__int12>__int1</__int12><__num11>__int1</__num11></a></foo>'
        generated_xml = util.dict2xml(d, 'foo', pretty=False)
        generated_d = util.xml2dict(generated_xml)
        self.assertEqual(generated_xml, desired_output)
        self.assertEqual(generated_d, d)

        d = {'a': {'aa': 1,
                   'ab': 1,},
             'b': {'ba': 2,
                   'bb': 2,},}
        desired_output = '<?xml version="1.0" ?><foo><a><aa>__int1</aa><ab>__int1</ab></a><b><ba>__int2</ba><bb>__int2</bb></b></foo>'
        generated_xml = util.dict2xml(d, 'foo', pretty=False)
        generated_d = util.xml2dict(generated_xml)
        self.assertEqual(generated_xml, desired_output)
        self.assertEqual(generated_d, d)


if __name__ == '__main__':
    unittest.main()
