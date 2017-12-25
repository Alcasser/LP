#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 24 14:47:58 2017

@author: alcasser
"""

class Estacio:
    'classe per a tractar estacions'
    
    totalEstacions = 0
    
    def __init__(self, nom, num, geo_pos):
        self.nom = nom
        self.num = num
        self.geo_pos = geo_pos
        self.totalEstacions += 1
        
    def get_pos(self):
        return self.geo_pos