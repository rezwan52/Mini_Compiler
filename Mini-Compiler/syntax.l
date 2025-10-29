%{
#include "y.tab.h"
#include <stdio.h>
int lineno = 1;
%}

%%
"int"|"float"|"char"     { printf("[Line %d] [TOKEN] TYPE (%s)\n", lineno, yytext); return TYPE; }
"if"                     { printf("[Line %d] [TOKEN] IF (%s)\n", lineno, yytext); return IF; }
"else"                   { printf("[Line %d] [TOKEN] ELSE (%s)\n", lineno, yytext); return ELSE; }
"while"                  { printf("[Line %d] [TOKEN] WHILE (%s)\n", lineno, yytext); return WHILE; }

[0-9]+(\.[0-9]+)?        { printf("[Line %d] [TOKEN] NUMBER (%s)\n", lineno, yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*   { printf("[Line %d] [TOKEN] ID (%s)\n", lineno, yytext); return ID; }
"="                      { printf("[Line %d] [TOKEN] ASSIGN (%s)\n", lineno, yytext); return ASSIGN; }
";"                      { printf("[Line %d] [TOKEN] SEMI (%s)\n", lineno, yytext); return SEMI; }
"("                      { printf("[Line %d] [TOKEN] LPAREN (%s)\n", lineno, yytext); return LPAREN; }
")"                      { printf("[Line %d] [TOKEN] RPAREN (%s)\n", lineno, yytext); return RPAREN; }
"{"                      { printf("[Line %d] [TOKEN] LBRACE (%s)\n", lineno, yytext); return LBRACE; }
"}"                      { printf("[Line %d] [TOKEN] RBRACE (%s)\n", lineno, yytext); return RBRACE; }
[\+\-\*/<>!]             { printf("[Line %d] [TOKEN] OP (%s)\n", lineno, yytext); return OP; }

\n                       { lineno++; }
[ \t\r]+                 ;   /* ignore whitespace */
.                        { printf("[Line %d] [TOKEN] UNKNOWN (%s)\n", lineno, yytext); return yytext[0]; }
%%

int yywrap() { return 1; }
