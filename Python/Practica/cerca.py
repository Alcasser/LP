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
            
TAG_NOM_ESDEVENIMENT = 'nom'
TAG_NOM_LLOC = 'nom'
TAG_LLOC_SIMPLE = 'lloc_simple'
TAG_ADRECA_SIMPLE = 'adreca_simple'
TAG_CARRER = 'carrer'
TAG_BARRI = 'barri'
TAG_DISTRICTE = 'districte'
TAG_DATA = 'data'
TAG_DATA_PROPER = 'data_proper_acte'
TAG_CLASSIFICACIONS = 'classificacions'
TAG_NIVELL = 'nivell'
TAG_COORDENADES = 'coordenades'
TAG_MAPS = 'googleMaps'
TAG_HORA_FI = 'hora_fi'
ATTR_LAT = 'lat'
ATTR_LON = 'lon'
TAG_PARADA = 'Punt'
TAG_NOM_METRO = 'Tooltip'
TAG_POS_PARADA = 'Coord'
TAG_LAT_PARADA = 'Latitud'
TAG_LON_PARADA = 'Longitud'
FORMAT_DATA_HORA = '%d/%m/%Y %H.%M'
FORMAT_HORA = '%H.%M'
EXPR_LM = 'L[0-9.]'

esdeveniments_infantils = True



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
        nom = xmlu.safe_find(acte, [TAG_NOM_ESDEVENIMENT])
        nom_lloc = xmlu.safe_find(acte, [TAG_LLOC_SIMPLE, TAG_NOM_LLOC])
        carrer = xmlu.safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                       TAG_CARRER])
        barri = xmlu.safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                      TAG_BARRI])
        districte = xmlu.safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                          TAG_DISTRICTE])
        date_i_str = xmlu.safe_find(acte, [TAG_DATA, TAG_DATA_PROPER])
        hora_f_str = xmlu.safe_find(acte, [TAG_DATA, TAG_HORA_FI])
        data_i = datetime.strptime(date_i_str, FORMAT_DATA_HORA)
            
        if not hora_f_str:
            data_f = data_i
        else:
            hora_f = datetime.strptime(hora_f_str, FORMAT_HORA)
            data_f = data_i.replace(hour = hora_f.hour, minute = hora_f.minute)
        
        classificacions = xmlu.safe_find(acte, [TAG_CLASSIFICACIONS], 'node')
        cl_str = ''
        for c in classificacions.iter(TAG_NIVELL):
            cl_str += c.text
        
        gmaps = xmlu.safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                    TAG_COORDENADES, TAG_MAPS], 'node')
        if not isinstance(gmaps, str):
            posicio = GeoPos(gmaps.attrib[ATTR_LAT], gmaps.attrib[ATTR_LON])
        else:
            posicio = GeoPos(0,0)
        return Esdeveniment(nom, nom_lloc, carrer, barri, districte, \
                            cl_str, data_i, data_f, posicio)
        
    root = ET.fromstring(xmlSource)
    actes = root.find('*//actes')
    return map(lambda a: build_event(a), actes)

def parse_estacions(xmlSource):
    def build_estacio(e):
        nom = xmlu.safe_find(e, [TAG_NOM_METRO])
        try:
            num = re.search(EXPR_LM, nom).group(0)
        except AttributeError as ae:
            num = -1
        lat = xmlu.safe_find(e, [TAG_POS_PARADA, TAG_LAT_PARADA])
        lng = xmlu.safe_find(e, [TAG_POS_PARADA, TAG_LON_PARADA])
        pos = GeoPos(lat, lng)
        return Estacio(nom, num, pos)
        
    root = ET.fromstring(xmlSource)
    estacions = root.iter(TAG_PARADA)
    return map(lambda e: build_estacio(e), estacions)

def search_metro(esd, estacions):
    estacions = filter(lambda est: est.get_pos().distancia(esd.get_pos()) \
                       <= 500, estacions)
    esd.set_transport(list(estacions))
    return esd

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
        def tostr(transports):
            t_nums = map(lambda t: str(t.num), transports)
            trs = functools.reduce(operator.add, t_nums, '')
            return trs
        lmetro = evaluateLiteral(args.metro)
        evalFunctions.append(lambda e: SE.evaluate(lmetro,
                                                   tostr(e.get_transport())))
    if esdeveniments_infantils:
        pass
        #evalFunctions.append(lambda e: SE.evaluate())
    return evalFunctions

def matches_search(event, evalFunctions):
    results = map(lambda ev_f: ev_f(event), evalFunctions)
    return functools.reduce(operator.and_, results, True)

def main():
    ad = FetchAdapter(url_esd, parse_esdeveniments)
    esdeveniments = ad.get_objects()
    ad = FetchAdapter(url_metro, parse_estacions)
    estacions = ad.get_objects()
    esdeveniments = map(lambda esd: search_metro(esd, estacions),
                       esdeveniments)
    evaluation_functions = search_criteria()
    srch_esds = filter(lambda e: matches_search(e, evaluation_functions),
                      esdeveniments)
    srch_esds_names = list(map(lambda e: e.nom,
                               list(srch_esds)))
    print(srch_esds_names)
    print(len(srch_esds_names))
    
    
if __name__ == "__main__":
    main()