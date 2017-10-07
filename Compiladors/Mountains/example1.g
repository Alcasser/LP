#header
<<
#include <string>
#include <iostream>
#include <map>
using namespace std;

// struct to store information about tokens
typedef struct {
  string kind; //nom token
  string text; //valor token
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

map<string,int> m;

// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  if (type == NUM) {
    attr->kind = "intconst";
    attr->text = text;
  }
  else if (type == ID) {
    attr->kind= "identifier";
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

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a,int n) {
 AST *c=a->down;
 for (int i=0; c!=NULL && i<n; i++) c=c->right;
 return c;
} 

/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a,string s)
{
  if (a==NULL) return;

  cout<<a->kind;
  if (a->text!="") cout<<"("<<a->text<<")";
  cout<<endl;

  AST *i = a->down;
  while (i!=NULL && i->right!=NULL) {
    cout<<s+"  \\__";
    ASTPrintIndent(i,s+"  |"+string(i->kind.size()+i->text.size(),' '));
    i=i->right;
  }
  
  if (i!=NULL) {
      cout<<s+"  \\__";
      ASTPrintIndent(i,s+"   "+string(i->kind.size()+i->text.size(),' '));
      i=i->right;
  }
}

/// print AST 
void ASTPrint(AST *a)
{
  while (a!=NULL) {
    cout<<" ";
    ASTPrintIndent(a,"");
    a=a->right;
  }
}

int evaluate(AST *a) {
  if (a == NULL) return 0;
  else if (a->kind == "intconst")
    return atoi(a->text.c_str());
  else if (a->kind == "identifier")
    return m[a->text.c_str()];
  else if (a->kind == "*")
    return evaluate(child(a,0)) * evaluate(child(a,1));
  else if (a->kind == "+")
    return evaluate(child(a,0)) + evaluate(child(a,1));
  else if (a->kind == "-")
    return evaluate(child(a,0)) - evaluate(child(a,1));
  else if (a->kind == ">")
    return evaluate(child(a,0)) > evaluate(child(a,1));
  else if (a->kind == "<")
    return evaluate(child(a,0)) < evaluate(child(a,1));
}

void execute(AST *a) {
   if (a == NULL)
     return;
   else if (a->kind == ":=")
     m[child(a,0)->text] = evaluate(child(a,1));
   else if (a->kind == "while") {
     while(evaluate(child(a,0))) {
       int i = 0;
       while(child(a,++i) != NULL)
        execute(child(a,i));
     }
   }
   else // a->kind == "write"
     cout << evaluate(child(a,0)) << endl;
   
   execute(a->right);
 }

int main() {
  AST *root = NULL;
  ANTLR(program(&root), stdin);
  ASTPrint(root);
  execute(root);
}

>>

#lexclass START
#token NUM "[0-9]+"
#token WRITE "write"
#token WHILE "while"
#token EWHILE "endwhile"
#token DO "do"
#token ID "[a-zA-Z]+"
#token ASIG ":="
#token PLUS "\+"
#token MINUS "\-"
#token TIMES "\*"
#token DIVIDED "\/"
#token LPAR "\("
#token RPAR "\)"
#token GTHAN ">"
#token LTHAN "<"
#token SPACE "[\ \n]" << zzskip();>>

//expr: NUM (PLUS^ NUM)* ;
//expr: NUM ((PLUS^ | MINUS^) expr | );
//parexpr: LPAR! expr RPAR! ;
//atom: NUM | parexpr ;
//term: atom ((TIMES^ | DIVIDED^) term | );
//expr: term ((PLUS^ | MINUS^) expr | );
//input: expr "@";
//------------------------
parexpr: LPAR! expr RPAR! ;
atom: NUM | ID | parexpr ;
term: atom ((TIMES^ | DIVIDED^) atom)*;
expr: term ((PLUS^ | MINUS^) term)*;
cond: expr ((GTHAN^ | LTHAN^) expr | );
instruction: (ID ASIG^ expr | WRITE^ expr | WHILE^ cond DO! (instruction)* EWHILE!);
program: (instruction)* ;
