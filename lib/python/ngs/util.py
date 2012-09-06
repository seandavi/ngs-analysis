#!/usr/bin/env python

import re
import xml.dom.minidom


def load_dict(fin, key_col=0, val_col=1, delim='\t'):
    '''
    From a multiple-column file, build a dictionary
    '''
    d = {}
    with fin:
        for line in fin:
            la = line.strip().split(delim)
            k = la[key_col]
            v = la[val_col]
            d[k] = v
    return d    

#------------------------------------------------------------------------------------------------
# XML

# Prefixes to prepend to each key or value in order to ensure proper conversion back to dictionary
DATA_PREFIX = {'INTEGER': '__int',
               'NUMERIC': '__num',}

def prepend_value_type(val):
    '''
    Given a value val, prepend the correct prefix in PREFIX so that xml generation and parsing
    can be done correctly to produce proper data types
    '''
    # Check data type of val
    # Integer
    if isinstance(val, int):
        val = DATA_PREFIX['INTEGER'] + str(val)
    # Numeric string
    elif isinstance(val, str) and val.isdigit():
        val = DATA_PREFIX['NUMERIC'] + val

    return str(val)

def remove_value_type_and_convert(prefixed_val):
    '''
    Given a prefixed value prefixed_val, remove the prefix and convert the data to the proper
    data type
    If no prefixes are detected, simply convert to string and return the value
    '''
    convert_fnc = {DATA_PREFIX['INTEGER']: lambda x: int(x),
                   DATA_PREFIX['NUMERIC']: lambda x: str(x)}

    for k,prefx in DATA_PREFIX.iteritems():
        if re.match(prefx, prefixed_val):
            return convert_fnc[prefx](prefixed_val.replace(prefx, ''))
    return str(prefixed_val)

def dict2xml(d, name='data', pretty=False):
    '''
    Convert a multi-level dictionary to xml using recursion
    Inputs
      d:    dictionary
      name: name of outermost xml element
    '''

    # Inner function for recursion
    def generate_subelements_from_dict(_parent_el, _d):
        '''
        Given a dictionary d, recursively generate child elements and append them to element el
        '''
        for _k in sorted(_d.keys()):
            if isinstance(_d[_k], dict):
                
                # Prepend proper prefix for data type
                _k = prepend_value_type(_k)
                _el = doc.createElement(str(_k))
                _parent_el.appendChild(_el)
                generate_subelements_from_dict(_el, _d[_k])
            else:
                # Create the value text node
                _val = prepend_value_type(_d[_k])
                _value = doc.createTextNode(_val)

                # Create the key element and append the value text node
                _k = prepend_value_type(_k)
                _el = doc.createElement(_k)
                _el.appendChild(_value)

                # Attach the key element to the parent element
                _parent_el.appendChild(_el)

    # Initialize xml doc
    doc = xml.dom.minidom.Document()
    el0 = doc.createElement(name)
    doc.appendChild(el0)

    # Generate child elements to doc
    generate_subelements_from_dict(el0, d)

    if pretty:
        return doc.toprettyxml()
    return doc.toxml()


def xml2dict(xml_str):
    '''
    Read in xml string, and generate a multi-level dictionary
    Note: There may be some value type errors since data types are converted to string, etc
    '''
    
    def generate_subdict(_el):
        '''
        Takes in a xml node element, and recursivesly generates a multi-level dictionary
        '''
        _d = {}
        for cn in _el.childNodes:
            # Reached the leaves
            if cn.nodeType == cn.TEXT_NODE:
                return remove_value_type_and_convert(cn.data)
            # Recursive call
            else:
                _d[remove_value_type_and_convert(cn.nodeName)] = generate_subdict(cn)
        return _d

    # Parse the xml string
    dom = xml.dom.minidom.parseString(xml_str)

    # Extract the outermost element and generate dictionary
    return generate_subdict(dom.firstChild)

