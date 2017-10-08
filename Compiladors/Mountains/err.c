/*
 * A n t l r  S e t s / E r r o r  F i l e  H e a d e r
 *
 * Generated from: mountains.g
 *
 * Terence Parr, Russell Quong, Will Cohen, and Hank Dietz: 1989-2001
 * Parr Research Corporation
 * with Purdue University Electrical Engineering
 * With AHPCRC, University of Minnesota
 * ANTLR Version 1.33MR33
 */

#define ANTLR_VERSION	13333
#include "pcctscfg.h"
#include "pccts_stdio.h"

#include <string>
#include <iostream>
#include <map>
#include <vector>
using namespace std;

// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;

// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);
#define zzSET_SIZE 8
#include "antlr.h"
#include "ast.h"
#include "tokens.h"
#include "dlgdef.h"
#include "err.h"

ANTLRChar *zztokens[33]={
	/* 00 */	"Invalid",
	/* 01 */	"@",
	/* 02 */	"NUM",
	/* 03 */	"MULT",
	/* 04 */	"PUJADA",
	/* 05 */	"CIM",
	/* 06 */	"BAIXADA",
	/* 07 */	"CONCAT",
	/* 08 */	"AND",
	/* 09 */	"OR",
	/* 10 */	"NOT",
	/* 11 */	"IF",
	/* 12 */	"ENDIF",
	/* 13 */	"WHILE",
	/* 14 */	"ENDWHILE",
	/* 15 */	"ASIG",
	/* 16 */	"MSIM",
	/* 17 */	"WSIM",
	/* 18 */	"HSIM",
	/* 19 */	"DSIM",
	/* 20 */	"PSIM",
	/* 21 */	"VSIM",
	/* 22 */	"CSIM",
	/* 23 */	"ID",
	/* 24 */	"ALM",
	/* 25 */	"PLUS",
	/* 26 */	"LPAR",
	/* 27 */	"RPAR",
	/* 28 */	"GTHAN",
	/* 29 */	"LTHAN",
	/* 30 */	"EQUAL",
	/* 31 */	"COMA",
	/* 32 */	"SPACE"
};
SetWordType zzerr1[8] = {0x0,0x0,0x80,0x1, 0x0,0x0,0x0,0x0};
SetWordType zzerr2[8] = {0x4,0x0,0x87,0x1, 0x0,0x0,0x0,0x0};
SetWordType zzerr3[8] = {0x20,0x0,0x0,0x2, 0x0,0x0,0x0,0x0};
SetWordType zzerr4[8] = {0x0,0x0,0x30,0x0, 0x0,0x0,0x0,0x0};
SetWordType zzerr5[8] = {0x70,0x0,0x0,0x0, 0x0,0x0,0x0,0x0};
SetWordType setwd1[33] = {0x0,0x0,0x0,0x7a,0x0,0x76,0x0,
	0xfa,0x72,0x72,0x0,0xfa,0xfa,0xfa,0xfa,
	0x0,0x0,0x0,0x0,0xfa,0x0,0x0,0xfa,
	0xfb,0x1,0x76,0x0,0xfa,0x72,0x72,0x72,
	0xfa,0x0};
SetWordType zzerr6[8] = {0x4,0x0,0xb7,0x1, 0x0,0x0,0x0,0x0};
SetWordType zzerr7[8] = {0x0,0x0,0x0,0x70, 0x0,0x0,0x0,0x0};
SetWordType zzerr8[8] = {0x0,0x3,0x0,0x78, 0x0,0x0,0x0,0x0};
SetWordType setwd2[33] = {0x0,0x0,0x2,0x0,0x0,0x0,0x0,
	0x9,0x80,0x80,0x0,0x39,0x39,0x39,0x39,
	0x0,0x2,0x2,0x2,0x39,0x4,0x4,0x39,
	0x3b,0x2,0x0,0x0,0x99,0x40,0x40,0x40,
	0x19,0x0};
SetWordType zzerr9[8] = {0x0,0x3,0x0,0x8, 0x0,0x0,0x0,0x0};
SetWordType zzerr10[8] = {0x0,0x2,0x0,0x8, 0x0,0x0,0x0,0x0};
SetWordType zzerr11[8] = {0x4,0x4,0x87,0x1, 0x0,0x0,0x0,0x0};
SetWordType setwd3[33] = {0x0,0x0,0x10,0x0,0x0,0x0,0x0,
	0x0,0x1,0x7,0x0,0xc0,0xc0,0xc0,0xc0,
	0x0,0x10,0x10,0x10,0xc0,0x0,0x0,0xc0,
	0xd0,0x10,0x0,0x0,0x2f,0x0,0x0,0x0,
	0x0,0x0};
SetWordType setwd4[33] = {0x0,0x0,0x0,0x0,0x0,0x0,0x0,
	0x0,0x0,0x0,0x0,0x7,0xb,0x7,0xb,
	0x0,0x0,0x0,0x0,0x7,0x0,0x0,0x7,
	0x7,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
	0x0,0x0};
