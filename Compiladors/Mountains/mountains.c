/*
 * A n t l r  T r a n s l a t i o n  H e a d e r
 *
 * Terence Parr, Will Cohen, and Hank Dietz: 1989-2001
 * Purdue University Electrical Engineering
 * With AHPCRC, University of Minnesota
 * ANTLR Version 1.33MR33
 *
 *   antlr -gt mountains.g
 *
 */

#define ANTLR_VERSION	13333
#include "pcctscfg.h"
#include "pccts_stdio.h"

#include <string>
#include <iostream>
#include <map>
#include <vector>
#include <regex>
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
#define GENAST

#include "ast.h"

#define zzSET_SIZE 8
#include "antlr.h"
#include "tokens.h"
#include "dlgdef.h"
#include "mode.h"

/* MR23 In order to remove calls to PURIFY use the antlr -nopurify option */

#ifndef PCCTS_PURIFY
#define PCCTS_PURIFY(r,s) memset((char *) &(r),'\0',(s));
#endif

#include "ast.c"
zzASTgvars

ANTLR_INFO

#include <cstdlib>
#include <cmath>

//global structures
AST *root;

map<string,string> m;
map<string,int> v;

//config
const bool colors = true;

//errors
const int UNDEFINED_VARIABLE = 0;
const int WRONG_CONCATENATION = 1;
const int WRONG_ADDITION = 2;
const int WRONG_COMPARATION = 3;
const int WRONG_BOOLEAN_EXPRESSION = 4;
const int WRONG_MOUNTAIN_FUNCTION = 5;
const int WRONG_ASSIGNMENT = 6;
const int WRONG_PART_CREATION = 7;

// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  if (type == ID) {
    attr->kind = "identifier";
    attr->text = text;
  }
  else if (type == NUM) {
    attr->kind = "intconst";
    attr->text = text;
  }
  else if (type == PUJADA || type == CIM || type == BAIXADA) {
    attr->kind = "part";
    attr->text = text;
  }
  else {
    attr->kind = text;
    attr->text = "";
  }
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind; 
  as->text = attr->text;
  as->right = NULL; 
  as->down = NULL;
  return as;
}

/// create a new "list" AST node with one element
AST* createASTlist(AST *child) {
  AST *as = new AST;
  as->kind = "list";
  as->right = NULL;
  as->down = child;
  return as;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a, int n) {
  AST *c = a->down;
  for (int i=0; c!=NULL && i<n; i++) c = c->right;
  return c;
}


/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a, string s) {
  if (a == NULL) return;
  
  cout << a->kind;
  if (a->text != "") cout << "(" << a->text << ")";
  cout << endl;
  
  AST *i = a->down;
  while (i != NULL && i->right != NULL) {
    cout << s+"  \\__";
    ASTPrintIndent(i, s+"  |"+string(i->kind.size()+i->text.size(), ' '));
    i = i->right;
  }
  
  if (i != NULL) {
    cout << s+"  \\__";
    ASTPrintIndent(i, s+"   "+string(i->kind.size()+i->text.size(), ' '));
    i = i->right;
  }
}

/// print AST 
void ASTPrint(AST *a) {
  while (a != NULL) {
    cout << " ";
    ASTPrintIndent(a, "");
    a = a->right;
  }
}

bool mountainWellformed(string mountain) {
  regex mountainRegex ("^((\\/+-+\\\\+)|(\\\\+-+\\/+))+$");
  return regex_match(mountain, mountainRegex);
}

int mountainHeight(string mountain) {
  int max, min, level;
  max = min = level = 0;
  for (int i = 0; i < mountain.length(); i++) {
    if (mountain[i] == '/') ++level;
    else if (mountain[i] == '\\') --level;
    if (level > max) max = level;
    if (level < min) min = level;
  }
  return (max - min);
}

string completeMountain(string mountain) {
  if (mountainWellformed(mountain)) return mountain;
  else {
    char last = mountain.back();
    if (last == '/' and mountainWellformed(mountain + "-\\")) return mountain + "-\\";
    else if (last == '-') {
      if (mountainWellformed(mountain + "\\")) return mountain + "\\";
      if (mountainWellformed(mountain + "/")) return mountain + "\/";
    }
    else if (mountainWellformed(mountain + "-/")) return mountain + "-/";
  }
  return "";
}

string throwError(int error, string extras) {
  string emessage = "";
  switch(error) {
    case UNDEFINED_VARIABLE:
    emessage = "Undefined variable: ";
    break;
    case WRONG_CONCATENATION:
    emessage = "Valid concatenations are only allowed with defined mountains, parts, Peaks or Valleys.";
    break;
    case WRONG_ADDITION:
    emessage = "Addition is only allowed with integers (constants, variables or heights).";
    break;
    case WRONG_COMPARATION:
    emessage = "Expected an integer (constants, variables or heights) in operation: ";
    break;
    case WRONG_BOOLEAN_EXPRESSION:
    emessage = "Expected a boolean expression in operation: ";
    break;
    case WRONG_MOUNTAIN_FUNCTION:
    emessage = "Only mountain expressions or variables are allowed in function: ";
    break;
    case WRONG_ASSIGNMENT:
    emessage = "Variables can only be assigned to positive integer values, mountain definitions or other variables";
    break;
    case WRONG_PART_CREATION:
    emessage = "Incorrect mountain part expression. Parts are defined as triples of ( integer , \* , [\\ - /] )";
    break;
  }
  if (!extras.empty()) emessage += extras + '.';
  if (colors) emessage = "\033[1;31m" + emessage + "\033[0m";
  return emessage;
}

void saveVariable(string varName, int number, string mountain) {
  if (number != -1) {
    if (m.count(varName)) m.erase(varName);
    v[varName] = number;
  } else {
    if (v.count(varName)) v.erase(varName);
    m[varName] = mountain;
  }
}

string evaluate(AST *a, int& num, bool& cond) throw(string) {
  if (a == NULL) {
    num = -1;
    return "";
  }
  int tmp1 = -1;
  string tmp2 = "";
  if (a->kind == ";") {
    string part1, part2;
    part1 = evaluate(child(a,0), num, cond);
    part2 = evaluate(child(a,1), num, cond);
    if (part1.empty() or part2.empty()) throw throwError(WRONG_CONCATENATION, "");
    return part1 + part2;
  } else if (a->kind == "*") {
    int size = -1;
    string part = "";
    evaluate(child(a,0), size, cond);
    part = evaluate(child(a,1), num, cond);
    if (part.empty() or size == -1) throw throwError(WRONG_PART_CREATION, "");
    return string(size, part[0]);
  } else if (a->kind == "identifier") {
    if (m.count(a->text.c_str())) {
      return m[a->text.c_str()];
    } else if (v.count(a->text.c_str())){
      num = v[a->text.c_str()];
    } else {
      throw throwError(UNDEFINED_VARIABLE, a->text.c_str());
    }
  } else if (a->kind == "part") {
    return a->text.c_str();
  } else if (a->kind == "intconst") {
    num = stoi(a->text.c_str()); 
  } else if (a->kind == "Valley" || a->kind == "Peak") {
    int f, s, t;
    f = s = t = -1;
    evaluate(child(a,0), f, cond);
    evaluate(child(a,1), s, cond);
    evaluate(child(a,2), t, cond);
    if (f == -1 or s == -1 or t == -1) throw throwError(WRONG_MOUNTAIN_FUNCTION, a->kind);
    if (a->kind == "Peak")
    return string(f, '\/') + string(s, '\-') + string(t, '\\');
    else
    return string(f, '\\') + string(s, '\-') + string(t, '\/');
  } else if (a->kind == "NOT") {
    bool reseval;
    tmp2 = evaluate(child(a,0), tmp1, reseval);
    if (!tmp2.empty() or tmp1 != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
    cond = !reseval;
  } else if (a->kind == "OR") {
    bool ba, bb;
    tmp2 = evaluate(child(a,0), tmp1, ba);
    if (!tmp2.empty() or tmp1 != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
    tmp2 = evaluate(child(a,1), tmp1, bb);
    if (!tmp2.empty() or tmp1 != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
    cond = ba || bb;
  } else if (a->kind == "AND") {
    bool ba, bb;
    tmp2 = evaluate(child(a,0), tmp1, ba);
    if (!tmp2.empty() or tmp1 != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
    tmp2 = evaluate(child(a,1), tmp1, bb);
    if (!tmp2.empty() or tmp1 != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
    cond = ba && bb;
  } else if (a->kind == "==") {
    int ia, ib;
    ia = ib = -1;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    if (ia < 0 or ib < 0) throw throwError(WRONG_COMPARATION, a->kind);
    cond = (ia == ib);
  } else if (a->kind == ">") {
    int ia, ib;
    ia = ib = -1;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    if (ia < 0 or ib < 0) throw throwError(WRONG_COMPARATION, a->kind);
    cond = (ia > ib);
  } else if (a->kind == "<") {
    int ia, ib;
    ia = ib = -1;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    if (ia < 0 or ib < 0) throw throwError(WRONG_COMPARATION, a->kind);
    cond = (ia < ib);
  } else if (a->kind == "+") {
    int ia, ib;
    ia = ib = -1;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    if (ia < 0 or ib < 0) throw throwError(WRONG_ADDITION, "");
    num = ia + ib;
  } else if (a->kind == "Match") {
    string m1 = evaluate(child(a,0), num, cond);
    string m2 = evaluate(child(a,1), num, cond);
    if (m1.empty() or m2.empty()) throw throwError(WRONG_MOUNTAIN_FUNCTION, a->kind);
    int h1, h2;
    h1 = mountainHeight(m1);
    h2 = mountainHeight(m2);
    cond = (h1 == h2);
  } else if (a->kind == "Height") {
    string m1 = evaluate(child(a,0), num, cond);
    if (m1.empty()) throw throwError(WRONG_MOUNTAIN_FUNCTION, a->kind);
    num = mountainHeight(m1);
  } else if (a->kind == "Wellformed") {
    string m1 = evaluate(child(a,0), num, cond);
    if (m1.empty()) throw throwError(WRONG_MOUNTAIN_FUNCTION, a->kind);
    cond = mountainWellformed(m1);
  }
  return "";
}

void execute(AST *a) throw(string) {
  try {
    int num = -1;
    string mountain = "";
    bool res;
    if (a == NULL) {
      return;
    } else if (a->kind == "is") {
      mountain = evaluate(child(a,1), num, res);
      if (mountain.empty() and num == -1) throw throwError(WRONG_ASSIGNMENT, "");
      else if (mountain.empty()) saveVariable(child(a,0)->text, num, "");
      else saveVariable(child(a,0)->text, -1, mountain);
    } else if (a->kind == "Draw") {
      mountain = evaluate(child(a,0), num, res);
      if (mountain.empty()) throw throwError(WRONG_MOUNTAIN_FUNCTION, a->kind);
      cout << mountain << endl;
    } else if (a->kind == "Complete") {
      mountain = evaluate(child(a,0), num, res);
      if (mountain.empty()) throw throwError(WRONG_MOUNTAIN_FUNCTION, a->kind);
      m[child(a,0)->text] = completeMountain(mountain);
    } else if (a->kind == "if") {
      if (!evaluate(child(a,0), num, res).empty() or num != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
      if (res) {
        execute(child(a,1)->down);
      }
    } else if (a->kind == "while") {
      if (!evaluate(child(a,0), num, res).empty()) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
      if (num != -1) throw throwError(WRONG_BOOLEAN_EXPRESSION, a->kind);
      while (res) {
        execute(child(a,1)->down);
        evaluate(child(a,0), num, res);
      }
    }
  } catch (string error) {
    cout << "Error: " << error << endl;
  }
  execute(a->right);
}

void descMountains(bool print) {
  map<string, string>::iterator it;
  for (it = m.begin(); it != m.end(); it++) {
    string mountain = m[it->first];
    if (mountainWellformed(mountain)) {
      cout << "L'altitud final de " << it->first << " és: " << mountainHeight(mountain) << endl;
    }
  }
}

int main() {
  root = NULL;
  ANTLR(input(&root), stdin);
  ASTPrint(root);
  execute(child(root,0));
  descMountains(false);
}

void
#ifdef __USE_PROTOS
atom(AST**_root)
#else
atom(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  if ( (LA(1)==NUM) ) {
    zzmatch(NUM); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
  }
  else {
    if ( (setwd1[LA(1)]&0x1) ) {
      {
        zzBLOCK(zztasp2);
        zzMake0;
        {
        if ( (LA(1)==ALM) ) {
          zzmatch(ALM);  zzCONSUME;
        }
        else {
          if ( (LA(1)==ID) ) {
          }
          else {zzFAIL(1,zzerr1,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
        }
        zzEXIT(zztasp2);
        }
      }
      zzmatch(ID); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
    }
    else {
      if ( (LA(1)==HSIM) ) {
        height(zzSTR); zzlink(_root, &_sibling, &_tail);
      }
      else {
        if ( (LA(1)==MSIM) ) {
          match(zzSTR); zzlink(_root, &_sibling, &_tail);
        }
        else {
          if ( (LA(1)==WSIM) ) {
            wellformed(zzSTR); zzlink(_root, &_sibling, &_tail);
          }
          else {zzFAIL(1,zzerr2,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
        }
      }
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x2);
  }
}

void
#ifdef __USE_PROTOS
expr(AST**_root)
#else
expr(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  atom(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    while ( (LA(1)==PLUS) ) {
      zzmatch(PLUS); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
      atom(zzSTR); zzlink(_root, &_sibling, &_tail);
      zzLOOP(zztasp2);
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x4);
  }
}

void
#ifdef __USE_PROTOS
match(AST**_root)
#else
match(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(MSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  mountain(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(COMA);  zzCONSUME;
  mountain(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x8);
  }
}

void
#ifdef __USE_PROTOS
wellformed(AST**_root)
#else
wellformed(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(WSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  mountain(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x10);
  }
}

void
#ifdef __USE_PROTOS
height(AST**_root)
#else
height(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(HSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  mountain(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x20);
  }
}

void
#ifdef __USE_PROTOS
peakvalley(AST**_root)
#else
peakvalley(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    if ( (LA(1)==PSIM) ) {
      zzmatch(PSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
    }
    else {
      if ( (LA(1)==VSIM) ) {
        zzmatch(VSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
      }
      else {zzFAIL(1,zzerr3,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
    zzEXIT(zztasp2);
    }
  }
  zzmatch(LPAR);  zzCONSUME;
  expr(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(COMA);  zzCONSUME;
  expr(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(COMA);  zzCONSUME;
  expr(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x40);
  }
}

void
#ifdef __USE_PROTOS
part(AST**_root)
#else
part(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  expr(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    if ( (LA(1)==MULT) ) {
      {
        zzBLOCK(zztasp3);
        zzMake0;
        {
        zzmatch(MULT); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
        {
          zzBLOCK(zztasp4);
          zzMake0;
          {
          if ( (LA(1)==PUJADA) ) {
            zzmatch(PUJADA); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
          }
          else {
            if ( (LA(1)==CIM) ) {
              zzmatch(CIM); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
            }
            else {
              if ( (LA(1)==BAIXADA) ) {
                zzmatch(BAIXADA); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
              }
              else {zzFAIL(1,zzerr4,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
            }
          }
          zzEXIT(zztasp4);
          }
        }
        zzEXIT(zztasp3);
        }
      }
    }
    else {
      if ( (setwd1[LA(1)]&0x80) ) {
      }
      else {zzFAIL(1,zzerr5,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x1);
  }
}

void
#ifdef __USE_PROTOS
mountexpr(AST**_root)
#else
mountexpr(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  if ( (setwd2[LA(1)]&0x2) ) {
    part(zzSTR); zzlink(_root, &_sibling, &_tail);
  }
  else {
    if ( (setwd2[LA(1)]&0x4) ) {
      peakvalley(zzSTR); zzlink(_root, &_sibling, &_tail);
    }
    else {zzFAIL(1,zzerr6,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x8);
  }
}

void
#ifdef __USE_PROTOS
mountain(AST**_root)
#else
mountain(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  mountexpr(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    while ( (LA(1)==CONCAT) ) {
      zzmatch(CONCAT); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
      mountexpr(zzSTR); zzlink(_root, &_sibling, &_tail);
      zzLOOP(zztasp2);
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x10);
  }
}

void
#ifdef __USE_PROTOS
assign(AST**_root)
#else
assign(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(ID); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(ASIG); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  mountain(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x20);
  }
}

void
#ifdef __USE_PROTOS
boolexpr4(AST**_root)
#else
boolexpr4(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  atom(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    if ( (setwd2[LA(1)]&0x40) ) {
      {
        zzBLOCK(zztasp3);
        zzMake0;
        {
        if ( (LA(1)==GTHAN) ) {
          zzmatch(GTHAN); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
        }
        else {
          if ( (LA(1)==LTHAN) ) {
            zzmatch(LTHAN); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
          }
          else {
            if ( (LA(1)==EQUAL) ) {
              zzmatch(EQUAL); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
            }
            else {zzFAIL(1,zzerr7,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
          }
        }
        zzEXIT(zztasp3);
        }
      }
      atom(zzSTR); zzlink(_root, &_sibling, &_tail);
    }
    else {
      if ( (setwd2[LA(1)]&0x80) ) {
      }
      else {zzFAIL(1,zzerr8,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd3, 0x1);
  }
}

void
#ifdef __USE_PROTOS
boolexpr3(AST**_root)
#else
boolexpr3(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    if ( (LA(1)==NOT) ) {
      zzmatch(NOT); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
    }
    else {
      if ( (setwd3[LA(1)]&0x2) ) {
      }
      else {zzFAIL(1,zzerr9,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
    zzEXIT(zztasp2);
    }
  }
  boolexpr4(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd3, 0x4);
  }
}

void
#ifdef __USE_PROTOS
boolexpr2(AST**_root)
#else
boolexpr2(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  boolexpr3(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    if ( (LA(1)==AND) ) {
      zzmatch(AND); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
      boolexpr2(zzSTR); zzlink(_root, &_sibling, &_tail);
    }
    else {
      if ( (setwd3[LA(1)]&0x8) ) {
      }
      else {zzFAIL(1,zzerr10,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd3, 0x10);
  }
}

void
#ifdef __USE_PROTOS
boolexpr(AST**_root)
#else
boolexpr(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  boolexpr2(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    if ( (LA(1)==OR) ) {
      zzmatch(OR); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
      boolexpr(zzSTR); zzlink(_root, &_sibling, &_tail);
    }
    else {
      if ( (LA(1)==RPAR) ) {
      }
      else {zzFAIL(1,zzerr11,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd3, 0x20);
  }
}

void
#ifdef __USE_PROTOS
condic(AST**_root)
#else
condic(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(IF); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  boolexpr(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  mountains(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(ENDIF);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd3, 0x40);
  }
}

void
#ifdef __USE_PROTOS
iter(AST**_root)
#else
iter(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(WHILE); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  boolexpr(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  mountains(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(ENDWHILE);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd3, 0x80);
  }
}

void
#ifdef __USE_PROTOS
draw(AST**_root)
#else
draw(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(DSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  mountain(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(RPAR);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd4, 0x1);
  }
}

void
#ifdef __USE_PROTOS
complete(AST**_root)
#else
complete(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(CSIM); zzsubroot(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(LPAR);  zzCONSUME;
  zzmatch(ID); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
  zzmatch(RPAR);  zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd4, 0x2);
  }
}

void
#ifdef __USE_PROTOS
mountains(AST**_root)
#else
mountains(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    for (;;) {
      if ( !((setwd4[LA(1)]&0x4))) break;
      if ( (LA(1)==ID) ) {
        assign(zzSTR); zzlink(_root, &_sibling, &_tail);
      }
      else {
        if ( (LA(1)==IF) ) {
          condic(zzSTR); zzlink(_root, &_sibling, &_tail);
        }
        else {
          if ( (LA(1)==DSIM) ) {
            draw(zzSTR); zzlink(_root, &_sibling, &_tail);
          }
          else {
            if ( (LA(1)==WHILE) ) {
              iter(zzSTR); zzlink(_root, &_sibling, &_tail);
            }
            else {
              if ( (LA(1)==CSIM) ) {
                complete(zzSTR); zzlink(_root, &_sibling, &_tail);
              }
              else break; /* MR6 code for exiting loop "for sure" */
            }
          }
        }
      }
      zzLOOP(zztasp2);
    }
    zzEXIT(zztasp2);
    }
  }
  (*_root) = createASTlist(_sibling);
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd4, 0x8);
  }
}

void
#ifdef __USE_PROTOS
input(AST**_root)
#else
input(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  mountains(zzSTR); zzlink(_root, &_sibling, &_tail);
  zzmatch(1); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd4, 0x10);
  }
}
