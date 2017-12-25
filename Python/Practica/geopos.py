#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 24 21:16:02 2017

@author: alcasser
"""
from math import radians, cos, sin, sqrt, atan2

class GeoPos:
    'Classe per a tractar una posició en lat, lng'

    radi_terra = 6371000

    def __init__(self, lat, lng):
        try:
            self.lat = radians(float(lat))
            self.lng = radians(float(lng))
        except ValueError as ve:
            self.lat = self.lng = 0

    def distancia(self, d2):
         dif_lat = self.lat - d2.lat
         dif_lng = self.lng - d2.lng
         
         p0 = sin(dif_lat/2)**2 + cos(d2.lng) * \
              cos(self.lng)* sin(dif_lng/2)**2
         c = 2*atan2(sqrt(p0), sqrt(1 - p0))
         
         return GeoPos.radi_terra * c