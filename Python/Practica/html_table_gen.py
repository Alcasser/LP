#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 28 14:37:59 2017

@author: alcasser
"""
import functools, operator
import unicodedata

def normalize(s):
    return ''.join((c for c in unicodedata.normalize('NFD', s) \
                    if unicodedata.category(c) != 'Mn'))
class HtmlTable:
    
    border_style = 1
    
    def __init__(self, contents, table_name):
        self.contents = contents
        self.table_name = table_name
        self.file_name = table_name + '.html'
    
    def __build_table(self, contents):
        def add_pre(l):
            l[-1] = '<pre>' + str(l[-1]) + '</pre>'
            return l
        contents = map(add_pre, contents)
        table = '<htm><body><h1>' + self.table_name + '</h1>'
        table += '<table border={}>\n'.format(HtmlTable.border_style)
        tre = lambda col: '<td>' + normalize(str(col)) + '</td>'
        trl = lambda lst: '<tr>' + \
                          functools.reduce(operator.add, map(tre, lst), '') + \
                          '</tr>\n'
        table = functools.reduce(operator.add, map(trl, contents), table)
        table += '</table></body></html>\n'
        return table
        
    def __write_file(self, source):
        with open(self.file_name, 'w') as fo:
            fo.write(source)
    
    def write_table(self):
        table_str = self.__build_table(self.contents)
        self.__write_file(table_str)
        return table_str