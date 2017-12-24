#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 24 14:33:40 2017

@author: alcasser
"""

def safe_find(node, names):
        i = 0
        while node and i < len(names):
            node = node.find(names[i])
            i += 1
        if node is None:
            return ''
        elif node.text is None:
            return ''
        else:
            return node.text