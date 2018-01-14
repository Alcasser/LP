#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 12 14:07:35 2018

@author: alcasser
"""
import re
import xml.etree.ElementTree as ET
from datetime import datetime
from estacio import Estacio
from geopos import GeoPos
from esdeveniment import Esdeveniment

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
CODI_EDAT = '0054702003'
TAG_NIVELL = 'nivell'
TAG_COORDENADES = 'coordenades'
TAG_MAPS = 'googleMaps'
TAG_HORA_FI = 'hora_fi'
ATTR_LAT = 'lat'
ATTR_LON = 'lon'
TAG_PARADA = 'Punt'
TAG_NOM_PARADA = 'Tooltip'
TAG_POS_PARADA = 'Coord'
TAG_LAT_PARADA = 'Latitud'
TAG_LON_PARADA = 'Longitud'
FORMAT_DATA_HORA = '%d/%m/%Y %H.%M'
FORMAT_DATA = '%d/%m/%Y'
FORMAT_HORA = '%H.%M'
EXPR_LM = 'L[0-9.]'
TIPUS_METRO = 'METRO'
TIPUS_INDEX = 0
ESTACIO_INDEX = 3

def fix_edat(edat):
    if not edat:
        return (-1, -1)
    vs = re.findall(r'\d+', edat)
    vs = sorted(list(map(lambda e: int(e), vs)))
    altres = '+' in edat
    if altres:
        return (vs[0], vs[-1], '+' + str(vs[-1]))
    else:
        return (vs[0], vs[-1])
        

def safe_find(node, names, mode = 'text'):
        i = 0
        while node and i < len(names):
            node = node.find(names[i])
            i += 1
        if node is None:
            return ''
        if mode != 'text':
            return node
        if node.text is None:
            return ''
        else:
            return node.text
    
def build_event(acte):
    nom = safe_find(acte, [TAG_NOM_ESDEVENIMENT])
    nom_lloc = safe_find(acte, [TAG_LLOC_SIMPLE, TAG_NOM_LLOC])
    carrer = safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                   TAG_CARRER])
    barri = safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                  TAG_BARRI])
    districte = safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                      TAG_DISTRICTE])
    date_i_str = safe_find(acte, [TAG_DATA, TAG_DATA_PROPER])
    hora_f_str = safe_find(acte, [TAG_DATA, TAG_HORA_FI])
    data_i = datetime.strptime(date_i_str, FORMAT_DATA_HORA)
        
    # Si resulta que l'esdeveniment no te hora final, es mostra el dia com
    # a data final.
    if not hora_f_str:
        data_f = data_i.date()
    else:
        hora_f = datetime.strptime(hora_f_str, FORMAT_HORA)
        data_f = data_i.replace(hour = hora_f.hour, minute = hora_f.minute)
    
    classificacions = safe_find(acte, [TAG_CLASSIFICACIONS], 'node')
    cl_str = ''
    edat_str = ''
    for c in classificacions.iter(TAG_NIVELL):
        if CODI_EDAT in c.attrib['codi']:
            edat_str += c.text
        cl_str += c.text + ' '
    edat = fix_edat(edat_str)

    gmaps = safe_find(acte, [TAG_LLOC_SIMPLE, TAG_ADRECA_SIMPLE,
                                TAG_COORDENADES, TAG_MAPS], 'node')
    if not isinstance(gmaps, str):
        posicio = GeoPos(gmaps.attrib[ATTR_LAT], gmaps.attrib[ATTR_LON])
    else:
        posicio = GeoPos(0,0)
    return Esdeveniment(nom, nom_lloc, carrer, barri, districte, \
                        cl_str, data_i, data_f, posicio, edat)

def build_estacio(e):
    desc = safe_find(e, [TAG_NOM_PARADA])
    try:
        num = re.search(EXPR_LM, desc).group(0)
    except AttributeError as ae:
        num = -1
    tipus = desc.split(' ')[TIPUS_INDEX]
    if tipus == TIPUS_METRO:
        estacio = desc.split(' ')[ESTACIO_INDEX]
        if estacio[-1] == '-':
            estacio = estacio[:-1]
    else:
        estacio = -1
    lat = safe_find(e, [TAG_POS_PARADA, TAG_LAT_PARADA])
    lng = safe_find(e, [TAG_POS_PARADA, TAG_LON_PARADA])
    pos = GeoPos(lat, lng)
    return Estacio(desc, tipus, estacio, num, pos)

def parse_esdeveniments(xmlSource):     
    root = ET.fromstring(xmlSource)
    actes = root.find('*//actes')
    return map(lambda a: build_event(a), actes)

def parse_estacions(xmlSource):        
    root = ET.fromstring(xmlSource)
    estacions = root.iter(TAG_PARADA)
    return map(lambda e: build_estacio(e), estacions)