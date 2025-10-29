%{
#include "y.tab.h"
#include <stdio.h>
int lineno = 1;
%}

%%

"int"|"float"|"char"     { return TYPE; }
[0-9]+(\.[0-9]+)?        { yylval.sval = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*   { yylval.sval = strdup(yytext); return ID; }
"="                      { return ASSIGN; }
";"                      { return SEMI; }
"("                      { return LPAREN; }
")"                      { return RPAREN; }
"{"                      { return LBRACE; }
"}"                      { return RBRACE; }
[\+\-\*/]                { yylval.sval = strdup(yytext); return OP; }
\n                       { lineno++; }
[ \t]+                   ;   /* ignore whitespace */
.                        { return yytext[0]; }

%%

int yywrap() { return 1; }
