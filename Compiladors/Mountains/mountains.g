#header
<<
#include <string>
#include <iostream>
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


// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  if (type == ID) {
     attr->kind = "id";
     attr->text = text;
  }
  else if (type == NUM) {
    attr->kind = "intconst";
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


int main() {
  root = NULL;
  ANTLR(mountains(&root), stdin);
  ASTPrint(root);
}
>>



#lexclass START
#token NUM "[0-9]+"
#token MULT "\*"
#token PUJADA "\/"
#token CIM "\-"
#token BAIXADA "\\"
#token CONCAT ";"
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
#token ID "[a-zA-Z0-9]+"
#token ALM "#"
#token PLUS "\+"
#token LPAR "\("
#token RPAR "\)"
#token GTHAN ">"
#token LTHAN "<"
#token EQUAL "=="
#token COMA ","
#token SPACE "[\ \t \n]" << zzskip(); >>


atom: NUM | (ALM! | )ID | height | match | wellformed;
expr: atom ((PLUS^ | CIM^) atom)*;

match: MSIM^ LPAR! mountain COMA! mountain RPAR!;
wellformed: WSIM^ LPAR! mountain RPAR!;
height: HSIM^ LPAR! mountain RPAR!;
peakvalley: (PSIM^ | VSIM^) LPAR! expr COMA! expr COMA! expr RPAR!;

part: expr (MULT^ (PUJADA | CIM | BAIXADA))*; // |) not working EOF unexpected (?)
mountexpr: part | peakvalley;
mountain: mountexpr (CONCAT^ mountexpr)*;
assign: ID ASIG^ mountain;

boolexpr3: atom ((GTHAN^ | LTHAN^ | EQUAL^) atom | );
boolexpr2: boolexpr3 (AND^ boolexpr2 | );
boolexpr: boolexpr2 (OR^ boolexpr | ) ;
boolx: (NOT^ | ) boolexpr;

condic: IF^ LPAR! boolx RPAR! mountains ENDIF!;
iter: WHILE^ LPAR! boolx RPAR! mountains ENDWHILE!;
draw: DSIM^ LPAR! mountain RPAR!;
complete: CSIM^ LPAR! mountain RPAR!;
instruction: assign | condic | draw | iter | complete;
mountains: (instruction)* << #0 = createASTlist(_sibling); >>;
//mountains: (assign | condic | draw | iter | complete)* << #0 = createASTlist(_sibling); >>;
