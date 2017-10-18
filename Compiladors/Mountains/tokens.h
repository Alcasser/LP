#ifndef tokens_h
#define tokens_h
/* tokens.h -- List of labelled tokens and stuff
 *
 * Generated from: mountains.g
 *
 * Terence Parr, Will Cohen, and Hank Dietz: 1989-2001
 * Purdue University Electrical Engineering
 * ANTLR Version 1.33MR33
 */
#define zzEOF_TOKEN 1
#define AND 2
#define OR 3
#define NOT 4
#define IF 5
#define ENDIF 6
#define WHILE 7
#define ENDWHILE 8
#define ASIG 9
#define MSIM 10
#define WSIM 11
#define HSIM 12
#define DSIM 13
#define PSIM 14
#define VSIM 15
#define CSIM 16
#define ALM 17
#define ID 18
#define NUM 19
#define MULT 20
#define PUJADA 21
#define CIM 22
#define BAIXADA 23
#define CONCAT 24
#define PLUS 25
#define LPAR 26
#define RPAR 27
#define GTHAN 28
#define LTHAN 29
#define EQUAL 30
#define DIFF 31
#define COMA 32
#define SPACE 33

#ifdef __USE_PROTOS
void atom(AST**_root);
#else
extern void atom();
#endif

#ifdef __USE_PROTOS
void expr(AST**_root);
#else
extern void expr();
#endif

#ifdef __USE_PROTOS
void match(AST**_root);
#else
extern void match();
#endif

#ifdef __USE_PROTOS
void wellformed(AST**_root);
#else
extern void wellformed();
#endif

#ifdef __USE_PROTOS
void height(AST**_root);
#else
extern void height();
#endif

#ifdef __USE_PROTOS
void peakvalley(AST**_root);
#else
extern void peakvalley();
#endif

#ifdef __USE_PROTOS
void part(AST**_root);
#else
extern void part();
#endif

#ifdef __USE_PROTOS
void mountexpr(AST**_root);
#else
extern void mountexpr();
#endif

#ifdef __USE_PROTOS
void mountain(AST**_root);
#else
extern void mountain();
#endif

#ifdef __USE_PROTOS
void assign(AST**_root);
#else
extern void assign();
#endif

#ifdef __USE_PROTOS
void boolexpr3(AST**_root);
#else
extern void boolexpr3();
#endif

#ifdef __USE_PROTOS
void boolexpr2(AST**_root);
#else
extern void boolexpr2();
#endif

#ifdef __USE_PROTOS
void boolexpr(AST**_root);
#else
extern void boolexpr();
#endif

#ifdef __USE_PROTOS
void boolx(AST**_root);
#else
extern void boolx();
#endif

#ifdef __USE_PROTOS
void condic(AST**_root);
#else
extern void condic();
#endif

#ifdef __USE_PROTOS
void iter(AST**_root);
#else
extern void iter();
#endif

#ifdef __USE_PROTOS
void draw(AST**_root);
#else
extern void draw();
#endif

#ifdef __USE_PROTOS
void complete(AST**_root);
#else
extern void complete();
#endif

#ifdef __USE_PROTOS
void mountains(AST**_root);
#else
extern void mountains();
#endif

#ifdef __USE_PROTOS
void input(AST**_root);
#else
extern void input();
#endif

#endif
extern SetWordType zzerr1[];
extern SetWordType zzerr2[];
extern SetWordType zzerr3[];
extern SetWordType zzerr4[];
extern SetWordType zzerr5[];
extern SetWordType setwd1[];
extern SetWordType zzerr6[];
extern SetWordType zzerr7[];
extern SetWordType zzerr8[];
extern SetWordType setwd2[];
extern SetWordType zzerr9[];
extern SetWordType zzerr10[];
extern SetWordType zzerr11[];
extern SetWordType setwd3[];
extern SetWordType setwd4[];
