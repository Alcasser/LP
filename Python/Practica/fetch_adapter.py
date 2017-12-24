#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 16:03:14 2017

@author: alcasser
"""
import urllib.request
import hashlib

class FetchAdapter:
    '''
    The intention of this class is to make the http requests, store the
    results of the response and obtain a list of objects when
    getObjects() is called. The objects are obtained reading the data and
    using the parseObjectFunction
    '''
        
    def __init__(self, url, parseObjectFunction, data_file_name = ''):
        self.url = url
        self.parseObjectFunction = parseObjectFunction
        self.data_file_name = data_file_name
        self.objects = []
        
    def __fetch_data(self):
        sock = urllib.request.urlopen(self.url) 
        source = sock.read()                         
        sock.close()
        self.__write_file(source)
        return source
    
    def __enc_file_name(self):
        if not self.data_file_name:
            file_name = self.url
        else:
            file_name = self.data_file_name
        return hashlib.sha256(file_name.encode()).hexdigest() + '.cache'
        
    def __write_file(self, source):
        f_n = self.__enc_file_name()
        with open(f_n, 'wb') as fo:
            fo.write(source)
    
    def __read_data(self):
        try:
            f_n = self.__enc_file_name()
            with open(f_n, 'rb') as fo:
                return fo.read()
        except FileNotFoundError as e:
            return self.__fetch_data()
        
    def __check_data(self):
        if not self.objects:
            source = self.__read_data()
            self.objects = self.parseObjectFunction(source)
        
    def get_objects(self):
        self.__check_data()
        return self.objects
        
    
    
        
    
    
        
               
    
