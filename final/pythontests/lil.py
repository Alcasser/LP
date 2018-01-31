#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 23 10:31:09 2018

@author: alcasser
"""

known = {0:0, 1:1}
to = {0:0, 1:1}
a = {0:0, 1:1} 
def fibonacci(n):
    if n in known:
        return known[n]
    res = fibonacci(n-1) + fibonacci(n-2)
    known[n] = res
    to['0'] = 'av'
    return res

print(fibonacci(5))
print(known)
print(to)

class Card():  
    suit_names = ['Clubs', 'Diamonds', 'Hearts', 'Spades']
    rank_names = [None, 'Ace', '2', '3', '4', '5', '6', '7',
              '8', '9', '10', 'Jack', 'Queen', 'King']
    
    def __init__(self, suit=0, rank=2):
        self.suit = suit
        self.rank = rank
    
    def __str__(self):
        return '%s of %s' % (Card.rank_names[self.rank],
                             Card.suit_names[self.suit])


class Deck():
    
    def __init__(self):
        self.cards = []
        for suit in range(4):
            for rank in range(1, 14):
                card = Card(suit, rank)
                self.cards.append(card)
                
class Hand(Deck):
    """Represents a hand of playing cards."""
    
    
    def __init__(self, label=''):
        super().__init__()
        self.r_cards = ['empty']
        self.label = label
        
print(vars(Hand('kek')))