#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""
from esdeveniment import Esdeveniment
from fetch_adapter import FetchAdapter
import search_evaluation_helpers as SE
import argparse
import ast
import xml.etree.ElementTree as ET
import operator, functools
from datetime import datetime


url = "http://w10.bcn.es/APPS/asiasiacache/peticioXmlAsia?id=199"

def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('-k', '--key', help = "consulta d'esdeveniments amb" +
                        ' paraules claus', type = str)
    parser.add_argument('-d', '--date', help = "consulta d'esdeveniments " +
                        'dins de dates concretes')
    return parser.parse_args()

def evaluateLiteral(lit):
    return ast.literal_eval(lit)

def showAll(root,blanks):
    print(blanks, root.tag, root.attrib, root.text)
    for child in root:
        showAll (child, blanks + "  ")

# Funció que inclou la lógica relacionada amb les característiques de les dades
def parseEsdeveniments(xmlSource):
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
    
    def buildEvent(acte):
        nom = safe_find(acte, ['nom'])
        nom_lloc = safe_find(acte, ['lloc_simple', 'nom'])
        carrer = safe_find(acte, ['lloc_simple', 'adreca_simple', 'carrer'])
        barri = safe_find(acte, ['lloc_simple', 'adreca_simple', 'barri'])
        districte = safe_find(acte, ['lloc_simple', 'adreca_simple', \
                                     'districte'])
        date_i_str = safe_find(acte, ['data', 'data_proper_acte'])
        hora_f_str = safe_find(acte, ['data', 'hora_fi'])
        data_i = datetime.strptime(date_i_str, '%d/%m/%Y %H.%M')
        if not hora_f_str:
            data_f = data_i
        else:
            hora_f = datetime.strptime(hora_f_str, '%H.%M')
            data_f = data_i.replace(hour = hora_f.hour, minute = hora_f.minute)  
        classificacions = acte.find('classificacions')
        cl_str = ''
        for c in classificacions.iter('nivell'):
            cl_str += c.text
        return Esdeveniment(nom, nom_lloc, carrer, barri, districte, \
                            cl_str, data_i, data_f)   
        
    root = ET.fromstring(xmlSource)
    actes = root.find('*//actes')
    return map(lambda a: buildEvent(a), actes)

def search_criteria():
    args = parseArgs()
    evalFunctions = []
    if args.key:
        key_search = evaluateLiteral(args.key)
        evalFunctions.append(lambda e: SE.evaluate_info(key_search, e.info))
    if args.date:
        search_dates = evaluateLiteral(args.date)
        evalFunctions.append(lambda e: SE.evaluate_dates(search_dates,
                                                         e.dates))
    return evalFunctions

def matches_search(event, evalFunctions):
    results = map(lambda ev_f: ev_f(event), evalFunctions)
    return functools.reduce(operator.and_, results, True)

def main():
    esd_a = FetchAdapter(url, parseEsdeveniments)
    esdeveniments = esd_a.get_objects()
    evaluation_functions = search_criteria()
    key_esds = filter(lambda e: matches_search(e, evaluation_functions),
                      esdeveniments)
    srch_esd = list(map(lambda e: e.nom, list(key_esds)))
    print(srch_esd)
    print(len(srch_esd))
    
    
    
    
if __name__ == "__main__":
    main()
