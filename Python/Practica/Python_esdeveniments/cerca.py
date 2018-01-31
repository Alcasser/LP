#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""

from fetch_adapter import FetchAdapter
from html_table_gen import HtmlTable
from subprocess import call
from datetime import datetime
import search_evaluation_helpers as SE
import bcn_opendata_helpers as BCN
import argparse
import ast
import operator
import functools

# per si es vol mirar amb tots els esdeveniments
# pot passar que no hi hagi cap esdeveniment infantil (segons l'edat)
esdeveniments_infantils = False


def parseArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument('-k', '--key', help="consulta d'esdeveniments amb" +
                        ' paraules claus relacionades', type=str)
    parser.add_argument('-d', '--date', help="consulta d'esdeveniments " +
                        'dins de dates concretes')
    parser.add_argument('-m', '--metro', help="consulta d'esdeveniments " +
                        'que disposin de parades de metro de les linies' +
                        ' especificades en un rang de maxim 500 metres')
    return parser.parse_args()


def evaluateLiteral(lit):
    return ast.literal_eval(lit)


def search_criteria():
    """
    seguit de funcions que s'evaluaran per veure si l'esdeveniments s'ha de
    mostrar a la taula
    """
    args = parseArgs()
    evalFunctions = []
    evalFunctions.append(lambda e: len(e.transport) > 0)
    # Esdeveniments planejats per l'any 9999 no es mostraran.
    evalFunctions.append(lambda e: e.get_dates()[0].year != 9999)
    if esdeveniments_infantils:
        evalFunctions.append(lambda e: e.edat[0] >= 0 and e.edat[1] <= 12)
    if args.key:
        key_search = evaluateLiteral(args.key)
        evalFunctions.append(lambda e: SE.evaluate(key_search, e.info))
    if args.date:
        search_dates = evaluateLiteral(args.date)
        if not isinstance(search_dates, list):
            search_dates = [search_dates]
        evalFunctions.append(lambda e: SE.evaluate_dates(search_dates,
                                                         e.get_dates()))
    if args.metro:
        search_metro = evaluateLiteral(args.metro)

        def evalmetro(esd):
            t_nums = map(lambda t: ' ' + str(t.num) + ' ', esd.transport[:5])
            t_nums_str = functools.reduce(operator.add, t_nums, ' ')
            return SE.evaluate(search_metro, t_nums_str)
        evalFunctions.append(evalmetro)

    return evalFunctions


def matches_search(event, evalFunctions):
    """
    en el moment en que alguna de les funcions retorna false, la resta de
    funcions no s'evaluen.
    """
    return all(map(lambda ev_f: ev_f(event), evalFunctions))


def search_metro(esd, estacions):
    """
    nomes volem les estacions de metro, ordenades i a menys de 500 metres.
    nomes les estacions (sense repetir pel fet de tenir diferents entrades).
    """
    e_metro = filter(lambda est: est.tipus == 'METRO' and
                     esd.geo_pos.distancia(est.geo_pos) <= 5000, estacions)
    e_metro = sorted(e_metro,
                     key=lambda est: est.geo_pos.distancia(esd.geo_pos))
    parades_metro = {}
    for e in e_metro:
        key = e.num + e.estacio
        if key not in parades_metro:
            parades_metro[key] = e
    esd.transport = list(parades_metro.values())
    return esd


def write_open_table(srch_esds):
    """
    es construeix la taula amb les dades que es volen mostrar i s'obre al
    navegador
    """
    def tracta_transport(esd):
        return functools.reduce(operator.add,
                                map(lambda t: t.desc + '\n',
                                    esd.transport[:5]), '')

    def tracta_edat(esd):
        if esd.edat[0] == -1:
            return 'sense restricció'
        else:
            return 'de {} a {} anys'.format(esd.edat[0], esd.edat[-1])

    def tracta_data(data):
        if isinstance(data, datetime):
            return data.strftime('%d/%m/%y, %H:%M')
        else:
            return data.strftime('%d/%m/%y')

    esd_data = [['Nom', 'Lloc', 'Adreça', 'Inici', 'Final',
                 'Edat nens', 'Metro']]
    esd_data += map(lambda e: [e.nom, e.nom_lloc, e.carrer,
                               tracta_data(e.data_i), tracta_data(e.data_f),
                               tracta_edat(e), tracta_transport(e)], srch_esds)
    ht = HtmlTable(esd_data, 'Esdeveniments infantils')
    ht.write_table()
    call(['open', ht.file_name])


def main():
    # recuperem les dades de esdeveniments i estacions
    ad = FetchAdapter(BCN.url_esd, BCN.parse_esdeveniments)
    esdeveniments = ad.get_objects()
    ad = FetchAdapter(BCN.url_metro, BCN.parse_estacions)
    estacions = ad.get_objects()

    # busquem les estacions de metro de cada esdeveniment
    esdeveniments = map(lambda esd: search_metro(esd, estacions),
                        esdeveniments)

    # filtrem els esdeveniments que compleixen els criteris de cerca
    evaluation_functions = search_criteria()
    esdeveniments = list(filter(lambda e: matches_search(e,
                                                         evaluation_functions),
                                esdeveniments))
    # ordenem els esdeveniments per data
    esdeveniments = sorted(esdeveniments, key=lambda esd: esd.get_dates()[0])

    # generem i mostrem la taula
    write_open_table(esdeveniments)


if __name__ == "__main__":
    main()
