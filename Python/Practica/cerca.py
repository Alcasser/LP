#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""

from esdeveniment import Esdeveniment
from fetch_adapter import FetchAdapter
from estacio import Estacio
from geopos import GeoPos
import search_evaluation_helpers as SE
import xml_utils as xmlu
import argparse
import ast
import re
import xml.etree.ElementTree as ET
import operator, functools
from datetime import datetime


url_esd = "http://w10.bcn.es/APPS/asiasiacache/peticioXmlAsia?id=199"
url_metro = "http://opendata-ajuntament.barcelona.cat/resources/bcn/" + \
            "TRANSPORTS%20GEOXML.xml"

def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('-k', '--key', help = "consulta d'esdeveniments amb" +
                        ' paraules claus', type = str)
    parser.add_argument('-d', '--date', help = "consulta d'esdeveniments " +
                        'dins de dates concretes')
    parser.add_argument('-m', '--metro', help = "consulta d'esdeveniments " +
                        'que disposin de parades de metro de les linies' +
                        ' especificades en un rang de maxim 500 m')
    return parser.parse_args()

def evaluateLiteral(lit):
    return ast.literal_eval(lit)

# Funció que inclou la lógica relacionada amb les característiques de les dades
def parse_esdeveniments(xmlSource):
    def build_event(acte):
        nom = xmlu.safe_find(acte, ['nom'])
        nom_lloc = xmlu.safe_find(acte, ['lloc_simple', 'nom'])
        carrer = xmlu.safe_find(acte,
                                ['lloc_simple', 'adreca_simple', 'carrer'])
        barri = xmlu.safe_find(acte, ['lloc_simple', 'adreca_simple', 'barri'])
        districte = xmlu.safe_find(acte, ['lloc_simple', 'adreca_simple', \
                                     'districte'])
        date_i_str = xmlu.safe_find(acte, ['data', 'data_proper_acte'])
        hora_f_str = xmlu.safe_find(acte, ['data', 'hora_fi'])
        data_i = datetime.strptime(date_i_str, '%d/%m/%Y %H.%M')
            
        if not hora_f_str:
            data_f = data_i
        else:
            hora_f = datetime.strptime(hora_f_str, '%H.%M')
            data_f = data_i.replace(hour = hora_f.hour, minute = hora_f.minute)
        
        classificacions = xmlu.safe_find(acte, ['classificacions'], 'node')
        cl_str = ''
        for c in classificacions.iter('nivell'):
            cl_str += c.text
        
        gmaps = xmlu.safe_find(acte, ['lloc_simple', 'adreca_simple',
                                    'coordenades', 'googleMaps'], 'node')
        if not isinstance(gmaps, str):
            posicio = GeoPos(gmaps.attrib['lat'], gmaps.attrib['lon'])
        else:
            posicio = GeoPos(0,0)
        return Esdeveniment(nom, nom_lloc, carrer, barri, districte, \
                            cl_str, data_i, data_f, posicio)   
        
    root = ET.fromstring(xmlSource)
    actes = root.find('*//actes')
    return map(lambda a: build_event(a), actes)

def parse_estacions(xmlSource):
    def build_estacio(e):
        nom = xmlu.safe_find(e, ['Tooltip'])
        try:
            num = re.search('[0-9.]', nom).group(0)
        except AttributeError as ae:
            num = -1
        lat = xmlu.safe_find(e, ['Coord', 'Latitud'])
        lng = xmlu.safe_find(e, ['Coord', 'Longitud'])
        pos = GeoPos(lat, lng)
        return Estacio(nom, num, pos)
        
    root = ET.fromstring(xmlSource)
    estacions = root.iter('Punt')
    return map(lambda e: build_estacio(e), estacions)

def search_metro(esd):
    pos_esd = esd.get_pos
    ad = FetchAdapter(url_metro, parse_estacions)
    estacions = ad.get_objects()
    estacions = filter(lambda e: e.get_pos().distancia(pos_esd) <= 500,
                       estacions)
    return estacions

def match_dates(esd):
    pass
    
def search_criteria():
    args = parseArgs()
    evalFunctions = []
    if args.key:
        key_search = evaluateLiteral(args.key)
        evalFunctions.append(lambda e: SE.evaluate(key_search, e.info))
    if args.date:
        search_dates = evaluateLiteral(args.date)
        evalFunctions.append(lambda e: SE.evaluate_dates(search_dates,
                                                         e.dates))
    if args.metro:
        lmetro = evaluateLiteral(args.metro)            
        #evalFunctions.append(lambda e: SE.evaluate_metro())
    return evalFunctions

def matches_search(event, evalFunctions):
    results = map(lambda ev_f: ev_f(event), evalFunctions)
    return functools.reduce(operator.and_, results, True)

def main():
    ad = FetchAdapter(url_esd, parse_esdeveniments)
    esdeveniments = ad.get_objects()
    
    evaluation_functions = search_criteria()
    srch_esds = filter(lambda e: matches_search(e, evaluation_functions),
                      esdeveniments)
    srch_esds_names = list(map(lambda e: e.classificacions, list(srch_esds)))
    print(srch_esds_names)
    print(len(srch_esds_names))
    
    
if __name__ == "__main__":
    main()
