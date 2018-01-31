#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 28 14:37:59 2017

@author: alcasser
"""
import functools
import operator
import unicodedata


def normalize(s):
    return ''.join((c for c in unicodedata.normalize('NFD', s)
                    if unicodedata.category(c) != 'Mn'))


class HtmlTable:

    border_style = 1

    def __init__(self, contents, table_name):
        self.contents = contents
        self.table_name = table_name
        self.file_name = table_name + '.html'

    def __build_hardcoded_table(self, contents):
        table = "<html><head><meta charset='UTF-8'></head><body>"
        table += '<h1>' + self.table_name + '</h1>'
        if (len(contents) > 1):
            def add_pre(l):
                l[-1] = '<pre>' + str(l[-1]) + '</pre>'
                return l

            def tre(col): return '<td>' + str(col) + '</td>'

            def trl(lst): return '<tr>' + \
                functools.reduce(operator.add, map(tre, lst), '') + '</tr>'

            contents = map(add_pre, contents)
            table += '<table border={}>\n'.format(HtmlTable.border_style)
            table = functools.reduce(operator.add, map(trl, contents), table)
            table += '</table>'
        else:
            table += '<h3> No hi han esdeveniments </h3>'
        table += '</body></html>\n'
        return table

    def __write_file(self, source):
        with open(self.file_name, 'w') as fo:
            fo.write(source)

    def write_table(self):
        table_str = self.__build_hardcoded_table(self.contents)
        self.__write_file(table_str)
        return table_str
