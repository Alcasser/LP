#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 28 14:37:59 2017

@author: alcasser
"""
import functools, operator

class HtmlTable:
    
    border_style = 1
    
    def __init__(self, contents, table_name):
        self.contents = contents
        self.table_name = table_name
    
    def __build_table(self, contents):
        table = '<htm><body><table border={}>\n'.format(HtmlTable.border_style)
        tre = lambda col: '<td>' + str(col) + '</td>'
        trl = lambda lst: '<tr>' + \
                          functools.reduce(operator.add, map(tre, lst), '') + \
                          '</tr>\n'
        table = functools.reduce(operator.add, map(trl, table_data), table)
        table += '</table></body></html>\n'
        return table
        
    def __write_file(self, source):
        f_n = self.table_name
        with open(f_n + '.html', 'w') as fo:
            fo.write(source)
    
    def write_table(self):
        table_str = self.__build_table(self.contents)
        self.__write_file(table_str)
        return table_str
    
if __name__ == "__main__":
    table_data = [
        ['Cognom',      'Nom',          'edat'],
        ['Smith',       'John',         30],
        ['Carpenter',   'Jack',         47],
        ['Johnson',     'Paul',         62],
    ]
    ht = HtmlTable(table_data, 'estudiants')
    print(ht.write_table())