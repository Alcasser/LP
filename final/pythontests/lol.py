#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 25 21:23:03 2018

@author: alcasser
"""

def evaluate(e):
    if isinstance(e, int):
        return e
    elif isinstance(e, list):
        t = 1
        for elem in e:
            elem = evaluate(elem)
            if elem:
                t *= elem
        return t
    elif isinstance(e, tuple):
        t = 0
        for elem in e:
            elem = evaluate(elem)
            if elem:
                t += elem
        return t

def s2(a,b):
    return a+b

def partial(func, x):
    def newfunc(*resta):
        l = [x] + resta
        return func(*l)
    return newfunc
            
def invert(l):
    if isinstance(l, list):
        return tuple((invert(elem) for elem in l))
    elif isinstance(l, tuple):
        return list([invert(elem) for elem in l ])
    else:
        return l
    
    
class BTree:
    def __init__ (self, x):
       self.rt = x
       self.left = None
       self.right = None
    def setLeft(self, a):
        self.left = a
    def setRight(self, a):
        self.right = a
    def root(self):
        return self.rt
    def leftChild (self):
        return self.left
    def rightChild (self):
        return self.right
    
class SBTree(BTree):
    def __init__(self, x):
        super().__init__(x)
        self.size = 1
    def setLeft(self, a):
        super().setLeft(a)
        self.size += a.getSize()
    def setRight(self, a):
        super().setRight(a)
        self.size += a.getSize()
    def getSize(self):
        return self.size
    def __minOccur_aux(self):
        occ = {}
        if self.left:
            occ1 = self.left.__minOccur_aux()
            occ = occ1
            print(occ)
        if self.right:
            occ2 = self.right.__minOccur_aux()
            print((occ2))
            for k in occ2:
                if k in occ:
                    occ[k] += occ2[k]
                else:
                    occ[k] = occ2[k]
        if self.rt in occ:
            occ[self.rt] += 1
        else:
            occ[self.rt] = 1
        return occ
        
    def minOccur(self):
        return self.__minOccur_aux()
        

a = SBTree(8)
a1 = SBTree(5)
a2 = SBTree(8)
a3 = SBTree(3)
a4 = SBTree(8)
a5 = SBTree(3)
a6 = SBTree(5)
a5.setRight(a6)
a3.setRight(a4)
a3.setLeft(a5)
a1.setLeft(a3)
a1.setRight(a2)
a.setLeft(a1)
print(a.minOccur())
        
    