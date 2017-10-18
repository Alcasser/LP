#header
<<
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
>>

<<
#include <cstdlib>
#include <cmath>

//global structures
AST *root;

map<string,string> m;
map<string,int> v;

//errors
const int UNDEFINED_VARIABLE = 0;
const int WRONG_CONCATENATION = 1;

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
    if (mountain[i] == '\/') ++level;
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
    if (last == '\/' and mountainWellformed(mountain + "-\\")) return mountain + "-\\";
    else if (last == '-') {
      if (mountainWellformed(mountain + "\\")) return mountain + "\\";
      if (mountainWellformed(mountain + "\/")) return mountain + "\/";
    }
    else if (mountainWellformed(mountain + "-\/")) return mountain + "-\/";
  }
  return "";
}

string trowError(int error, string extras) {
  string emessage = "";
  switch(error) {
    case UNDEFINED_VARIABLE:
      emessage = "Undefined variable ";
      break;
    case WRONG_CONCATENATION:
      emessage = "Valid concatenations are only with defined mountains, parts, Peaks or Valleys";
      break;
  }
  if (!extras.empty()) emessage += extras;
  return emessage;
}

string evaluate(AST *a, int& num, bool& cond) throw(string) {
  if (a == NULL) {
    num = -1;
    cond = false;
    return "";
  }
  else if (a->kind == ";") {
    string part1, part2;
    part1 = evaluate(child(a,0), num, cond);
    part2 = evaluate(child(a,1), num, cond);
    if (part1.empty() or part2.empty()) {
      throw trowError(WRONG_CONCATENATION, "");
    } else {
      return part1 + part2;
    }
  } else if (a->kind == "*") {
    int size;
    evaluate(child(a,0), size, cond);
    char part = evaluate(child(a,1), num, cond)[0];
    return string(size, part);
  } else if (a->kind == "identifier") {
    if (m.count(a->text.c_str())) {
      return m[a->text.c_str()];
    } else if (v.count(a->text.c_str())){
      num = v[a->text.c_str()];
    } else {
      throw trowError(UNDEFINED_VARIABLE, a->text.c_str());
    }
  } else if (a->kind == "part") {
    return a->text.c_str();
  } else if (a->kind == "intconst") {
    num = stoi(a->text.c_str()); 
  } else if (a->kind == "Valley" || a->kind == "Peak") {
    int f, s, t;
    evaluate(child(a,0), f, cond);
    evaluate(child(a,1), s, cond);
    evaluate(child(a,2), t, cond);
    cout << f << s << t << endl;
    if (a->kind == "Peak")
      return string(f, '\/') + string(s, '\-') + string(t, '\\');
    else
      return string(f, '\\') + string(s, '\-') + string(t, '\/');
  } else if (a->kind == "NOT") {
    bool reseval;
    evaluate(child(a,0), num, reseval);
    cond = !reseval;
  } else if (a->kind == "OR") {
    bool ba, bb;
    evaluate(child(a,0), num, ba);
    evaluate(child(a,1), num, bb);
    cond = ba || bb;
  } else if (a->kind == "AND") {
    bool ba, bb;
    evaluate(child(a,0), num, ba);
    evaluate(child(a,1), num, bb);
    cond = ba && bb;
  } else if (a->kind == "==") {
    int ia, ib;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    cond = (ia == ib);
  } else if (a->kind == "!=") {
    int ia, ib;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    cond = (ia != ib);
  } else if (a->kind == ">") {
    int ia, ib;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    cond = (ia > ib);
  } else if (a->kind == "<") {
    int ia, ib;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    cond = (ia < ib);
  } else if (a->kind == "+") {
    int ia, ib;
    evaluate(child(a,0), ia, cond);
    evaluate(child(a,1), ib, cond);
    num = ia + ib;
  } else if (a->kind == "Match") {
    int h1, h2;
    h1 = mountainHeight(evaluate(child(a,0), num, cond));
    h2 = mountainHeight(evaluate(child(a,1), num, cond));
    cond = (h1 == h2);
  } else if (a->kind == "Height") {
    num = mountainHeight(evaluate(child(a,0), num, cond));
  } else if (a->kind == "Wellformed") {
    cond = mountainWellformed(evaluate(child(a,0), num, cond));
  }
  return "";
}

void execute(AST *a) throw(string) {
  try {
   int num;
   string mountain;
   bool res;
   if (a == NULL) {
     return;
   } else if (a->kind == "is") {
     mountain = evaluate(child(a,1), num, res);
     if (mountain.empty()) v[child(a,0)->text] = num;
     else m[child(a,0)->text] = mountain;
   } else if (a->kind == "Draw") {
     cout << evaluate(child(a,0), num, res) << endl;
   } else if (a->kind == "Complete") {
     mountain = completeMountain(evaluate(child(a,0), num, res));
     if (!mountain.empty()) m[child(a,0)->text] = mountain;
   } else if (a->kind == "if") {
     evaluate(child(a,0), num, res);
     if (res) {
       execute(child(a,1)->down);
     }
   } else if (a->kind == "while") {
     evaluate(child(a,0), num, res);
     while (res) {
       execute(child(a,1)->down);
       evaluate(child(a,0), num, res);
     }
   }
   execute(a->right);
  } catch (string error) {
    throw;
  }
 }

void descMountains(bool print) {
  map<string, string>::iterator it;
  for (it = m.begin(); it != m.end(); it++) {
    string mountain = m[it->first];
    if (mountainWellformed(mountain)) {
      cout << "L'altitud final de " << it->first << " es: " << mountainHeight(mountain) << endl;
    }
  }
}

int main() {
  root = NULL;
  ANTLR(input(&root), stdin);
  ASTPrint(root);
  try {
    execute(child(root,0));
    descMountains(false);
  } catch (string error) {
    cout << "Error: " << error << endl;
    cout << "Error occurred. Finishing execution" << endl;
  }
}
>>



#lexclass START
#token AND "AND"
#token OR "OR"
#token NOT "NOT"
#token IF "if"
#token ENDIF "endif"
#token WHILE "while"
#token ENDWHILE "endwhile"
#token ASIG "is"
#token MSIM "Match"
#token WSIM "Wellformed"
#token HSIM "Height"
#token DSIM "Draw"
#token PSIM "Peak"
#token VSIM "Valley"
#token CSIM "Complete"
#token ALM "#"
#token ID "[a-zA-Z][a-zA-Z0-9]*"
#token NUM "[0-9]+"
#token MULT "\*"
#token PUJADA "\/"
#token CIM "\-"
#token BAIXADA "\\"
#token CONCAT ";"
#token PLUS "\+"
#token LPAR "\("
#token RPAR "\)"
#token GTHAN ">"
#token LTHAN "<"
#token EQUAL "=="
#token DIFF "!="
#token COMA ","
#token SPACE "[\ \t \n]" << zzskip(); >>


atom: NUM | (ALM! | )ID | height | match | wellformed;
expr: atom ((PLUS^ | CIM^) atom)*; // ((PLUS | MINUS))

match: MSIM^ LPAR! mountain COMA! mountain RPAR!;
wellformed: WSIM^ LPAR! mountain RPAR!;
height: HSIM^ LPAR! mountain RPAR!;
peakvalley: (PSIM^ | VSIM^) LPAR! expr COMA! expr COMA! expr RPAR!;

part: expr (MULT^ (PUJADA | CIM | BAIXADA))*; // |) not working EOF unexpected (?)
mountexpr: part | peakvalley;
mountain: mountexpr (CONCAT^ mountexpr)*;
assign: ID ASIG^ mountain;

boolexpr3: atom ((GTHAN^ | LTHAN^ | EQUAL^ | DIFF^) atom | );
boolexpr2: boolexpr3 (AND^ boolexpr2 | );
boolexpr: boolexpr2 (OR^ boolexpr | ) ;
boolx: (NOT^ | ) boolexpr;

condic: IF^ LPAR! boolx RPAR! mountains ENDIF!;
iter: WHILE^ LPAR! boolx RPAR! mountains ENDWHILE!;
draw: DSIM^ LPAR! mountain RPAR!;
complete: CSIM^ LPAR! ID RPAR!;
mountains: (assign | condic | draw | iter | complete)* << #0 = createASTlist(_sibling); >>;
input: mountains "@";
//mountains: (assign | condic | draw | iter | complete)* << #0 = createASTlist(_sibling); >>;