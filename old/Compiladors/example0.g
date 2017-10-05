#header 
<< #include "charptr.h" >>

<<
#include "charptr.c"

int main() {
   ANTLR(input(), stdin);
}
>>

#lexclass START
#token NUM "[0-9]+"
#token PLUS "\+"
#token MINUS "\-"
#token SPACE "[\ \n]" << zzskip(); >>

expr1: NUM (PLUS NUM)* "@";
operator: PLUS | MINUS;
expr: NUM (| operator expr);//expr1: NUM PLUS expr | NUM; (no esta factoritzada, no sap si es el cas base o recursiu)
input: expr "@";
