#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 24 21:16:02 2017

@author: alcasser
"""
from math import radians, cos, sin, sqrt, asin

class GeoPos:
    """
    Classe per a tractar una posició en lat, lng.
    Es calculen distàncies amb altres posicions amb la formula de Haversine
    """

    radi_terra = 6371000

    def __init__(self, lat, lng):
        try:
            self.lat = radians(float(lat))
            self.lng = radians(float(lng))
        except ValueError as ve:
            self.lat = self.lng = 0

    def distancia(self, d2):
         dif_lng = d2.lng - self.lng
         dif_lat = d2.lat - self.lat 
         
         p0 = sin(dif_lat/2)**2 + cos(self.lat) * \
              cos(d2.lat)* sin(dif_lng/2)**2
         c = 2 * asin(sqrt(p0))
         return GeoPos.radi_terra * c