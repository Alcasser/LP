#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""
from esdeveniment import Esdeveniment
import search_evaluation_helpers as SE
from fetch_adapter import FetchAdapter
import argparse
import ast
import xml.etree.ElementTree as ET
from datetime import datetime

url = "http://w10.bcn.es/APPS/asiasiacache/peticioXmlAsia?id=203"

def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--key", help = "consulta d'esdeveniments amb" +
                        " paraules claus", type = str)
    return parser.parse_args()

def evaluateKey(key):
    return ast.literal_eval(key)

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

def evalEsdeveniment(esd, key):
    info_esd = esd.get_info_str()
    return SE.evaluate(key, info_esd)

def main():
    args = parseArgs()
    key = evaluateKey(args.key)
    esd_a = FetchAdapter(url, 'esdeveniments.data', parseEsdeveniments)
    esdeveniments = esd_a.get_objects()
    key_esds = filter(lambda e: evalEsdeveniment(e, key), esdeveniments)
    print(len(list(map(lambda e: e.nom, list(key_esds)))))
    
    
    
    
if __name__ == "__main__":
    main()
