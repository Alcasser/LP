#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""
import unicodedata

def normalize(s):
    return ''.join((c for c in unicodedata.normalize('NFD', s) \
                    if unicodedata.category(c) != 'Mn')).lower()
        
def evaluate(lt, text):
    text = normalize(text)
    if isinstance(lt, list):
        return evaluate_list(lt, text)
    elif isinstance(lt, tuple):
        return evaluate_tuple(lt, text)
    else:
        return lt in text

def evaluate_list(l, text):
    for elem in l:
        if isinstance(elem, str):
            elem = normalize(elem)
            if elem not in text:
                return False
        if isinstance(elem, list):
            if (not evaluate_list(elem, text)):
                return False
        if isinstance(elem, tuple):
            if (not evaluate_tuple(elem, text)):
                return False
    return True

def evaluate_tuple(t, text):
    for elem in t:
        if isinstance(elem, str):
            elem = normalize(elem)
            if elem in text:
                return True
        if isinstance(elem, list):
            if (evaluate_list(elem, text)):
                return True
        if isinstance(elem, tuple):
            if (evaluate_tuple(elem, text)):
                return True
    return False
