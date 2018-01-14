#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 24 14:47:58 2017

@author: alcasser
"""

class Estacio:
    'classe per a tractar estacions'

    totalEstacions = 0
    
    def __init__(self, desc, tipus, estacio, num, geo_pos):
        self.desc = desc
        self.tipus = tipus
        self.num = num
        self.estacio = estacio
        self.geo_pos = geo_pos
        self.totalEstacions += 1