#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""
import unicodedata
import re
from datetime import datetime

def normalize(s):
    return ''.join((c for c in unicodedata.normalize('NFD', s) \
                    if unicodedata.category(c) != 'Mn')).lower()

def is_in(strn, wrd):
    return len(re.findall(r"\b" + wrd + r"\b", strn)) > 0
      
def evaluate(lt, text):
    text = normalize(text)
    if isinstance(lt, list):
        return evaluate_list(lt, text)
    elif isinstance(lt, tuple):
        return evaluate_tuple(lt, text)
    else:
        lt = normalize(lt)
        return is_in(text, lt)

def evaluate_list(l, text):
    for elem in l:
        if isinstance(elem, str):
            elem = normalize(elem)
            if not is_in(text, elem):
                return False
        if isinstance(elem, list):
            if (not evaluate_list(elem, text)):
                return False
        if isinstance(elem, tuple):
            if (not evaluate_tuple(elem, text)):
                return False
    return True

def evaluate_tuple(t, text):
    for elem in t:
        if isinstance(elem, str):
            elem = normalize(elem)
            if is_in(text, elem):
                return True
        if isinstance(elem, list):
            if (evaluate_list(elem, text)):
                return True
        if isinstance(elem, tuple):
            if (evaluate_tuple(elem, text)):
                return True
    return False

def evaluate_dates(search_dates, ev_dates):
    for date in search_dates:
        date_ev_ini = ev_dates[0].date()
        if isinstance(ev_dates[1], datetime):
            date_ev_fi = ev_dates[1].date()
        else:
            date_ev_fi = ev_dates[1]
        if isinstance(date, tuple):
            date_sch = datetime.strptime(date[0], '%d/%m/%Y')
            snds = 24 * 60 * 60
            tstamp_ini = snds * date[1]
            tstamp_fi = snds * date[2]
            date_sch_tst = datetime.timestamp(date_sch)
            date_sch_ini = datetime.fromtimestamp(date_sch_tst + tstamp_ini)\
                                   .date()
            date_sch_fi = datetime.fromtimestamp(date_sch_tst + tstamp_fi)\
                                   .date()
            if date_sch_ini <= date_ev_fi and date_sch_fi >= date_ev_ini:
                return True
        else:
            date_sch = datetime.strptime(date, '%d/%m/%Y').date()
            if date_ev_ini <= date_sch and date_sch <= date_ev_fi:
                return True
    return False
