#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""

test = ['a', 'b', 'c', 'd']

def evaluate_list(l):
    for elem in l:
        if isinstance(elem, str):
            if elem not in test:
                return False
        if isinstance(elem, list):
            if (not evaluate_list(elem)):
                return False
        if isinstance(elem, tuple):
            if (not evaluate_tuple(elem)):
                return False
    return True

def evaluate_tuple(t):
    for elem in t:
        if isinstance(elem, str):
            if elem in test:
                return True
        if isinstance(elem, list):
            if (evaluate_list(elem)):
                return True
        if isinstance(elem, tuple):
            if (evaluate_tuple(elem)):
                return True
    return False
