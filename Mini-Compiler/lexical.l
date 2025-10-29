%{
#include "syntax.tab.h"
#include <stdio.h>
int lineno = 1;
%}

%%

"int"|"float"|"char"     { printf("[Line %d] [TOKEN] TYPE (%s)\n", lineno, yytext); return TYPE; }
[0-9]+(\.[0-9]+)?        { printf("[Line %d] [TOKEN] NUMBER (%s)\n", lineno, yytext); yylval.fval = atof(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*   { printf("[Line %d] [TOKEN] ID (%s)\n", lineno, yytext); yylval.sval = strdup(yytext); return ID; }

"="      { printf("[Line %d] [TOKEN] ASSIGN (%s)\n", lineno, yytext); return ASSIGN; }
";"      { printf("[Line %d] [TOKEN] SEMI (%s)\n", lineno, yytext); return SEMI; }
"("      { printf("[Line %d] [TOKEN] LPAREN (%s)\n", lineno, yytext); return LPAREN; }
")"      { printf("[Line %d] [TOKEN] RPAREN (%s)\n", lineno, yytext); return RPAREN; }
"{"      { printf("[Line %d] [TOKEN] LBRACE (%s)\n", lineno, yytext); return LBRACE; }
"}"      { printf("[Line %d] [TOKEN] RBRACE (%s)\n", lineno, yytext); return RBRACE; }

"+"      { printf("[Line %d] [TOKEN] PLUS (%s)\n", lineno, yytext); return PLUS; }
"-"      { printf("[Line %d] [TOKEN] MINUS (%s)\n", lineno, yytext); return MINUS; }
"*"      { printf("[Line %d] [TOKEN] MUL (%s)\n", lineno, yytext); return MUL; }
"/"      { printf("[Line %d] [TOKEN] DIV (%s)\n", lineno, yytext); return DIV; }

\n       { lineno++; }
[ \t]+   ;
.        { printf("[Line %d] [TOKEN] UNKNOWN (%s)\n", lineno, yytext); return yytext[0]; }

%%

int yywrap() { return 1; }
