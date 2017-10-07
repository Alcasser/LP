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
#define NUM 2
#define MULT 3
#define PUJADA 4
#define CIM 5
#define BAIXADA 6
#define CONCAT 7
#define AND 8
#define OR 9
#define NOT 10
#define IF 11
#define ENDIF 12
#define WHILE 13
#define ENDWHILE 14
#define ASIG 15
#define MSIM 16
#define WSIM 17
#define HSIM 18
#define DSIM 19
#define PSIM 20
#define VSIM 21
#define CSIM 22
#define ID 23
#define ALM 24
#define PLUS 25
#define LPAR 26
#define RPAR 27
#define GTHAN 28
#define LTHAN 29
#define EQUAL 30
#define COMA 31
#define SPACE 32

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
void instruction(AST**_root);
#else
extern void instruction();
#endif

#ifdef __USE_PROTOS
void mountains(AST**_root);
#else
extern void mountains();
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
extern SetWordType zzerr12[];
extern SetWordType setwd4[];
