#!/usr/bin/env tcsh
antlr -gs example0.g
dlg parser.dlg scan.c
gcc -o example0 example0.c scan.c err.c
