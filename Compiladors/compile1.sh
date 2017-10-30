#!/usr/bin/env fish
antlr -gt example1.g
dlg -ci parser.dlg scan.c
g++ -o example1 example1.c scan.c err.c
rm -f  example1.c scan.c err.c parser.dlg tokens.h mode.h
