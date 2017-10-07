#!/usr/bin/env tcsh
antlr -gt mountains.g
dlg -ci parser.dlg scan.c
g++ -w -o mountains mountains.c scan.c err.c
