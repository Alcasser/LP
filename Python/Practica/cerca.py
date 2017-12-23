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

url = "http://w10.bcn.es/APPS/asiasiacache/peticioXmlAsia?id=199"

def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-k", "--key", help = "consulta d'esdeveniments amb" +
                        " paraules claus", type = str)
    return parser.parse_args()

def evaluateKey(key):
    keyLiterals = ast.literal_eval(key)
    print(SE.evaluate_list(keyLiterals))

def showAll(root,blanks):
    print(blanks, root.tag, root.attrib, root.text)
    for child in root:
        showAll (child, blanks + "  ")

def parseEsdeveniments(xmlSource):
    def buildEvent(acte):
        nom = acte.find('nom').text
        nom_lloc = acte.find('lloc_simple').find('nom').text
        adreca_simple = acte.find('lloc_simple') \
                           .find('adreca_simple')
        carrer = adreca_simple.find('carrer').text
        barri = adreca_simple.find('barri').text
        districte = adreca_simple.find('districte').text
        date_i_str = acte.find('data').find('data_proper_acte').text
        hora_f_str = acte.find('data').find('hora_fi').text
        data_i = datetime.strptime(date_i_str, '%d/%m/%Y %H.%M')
        if not hora_f_str:
            data_f = data_i
        else:
            hora_f = datetime.strptime(hora_f_str, '%H.%M')
            data_f = data_i.replace(hour = hora_f.hour, minute = hora_f.minute)
        
        return Esdeveniment(nom, nom_lloc, carrer, barri, districte, data_i, \
                            data_f)   
    root = ET.fromstring(xmlSource)
    actes = root.find('*//actes')
    return map(lambda a: buildEvent(a), actes)


def main():
    args = parseArgs()
    evaluateKey(args.key)
    esd_a = FetchAdapter(url, 'esdeveniments.data', parseEsdeveniments)
    print(list(esd_a.get_objects()))
    
    
    
if __name__ == "__main__":
    main()
