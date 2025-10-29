%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
%}

digit   [0-9]
id      [a-zA-Z_][a-zA-Z0-9_]*

%%

"="             { return ASSIGN; }
"+"             { return ADD; }
"-"             { return SUB; }
"*"             { return MUL; }
"/"             { return DIV; }
";"             { return SEMICOLON; }
{digit}+        { yylval.num = atoi(yytext); return NUMBER; }
{id}            { yylval.id = strdup(yytext); return ID; }
[ \t\n]+        { /* skip whitespace */ }
.               { return yytext[0]; }

%%

int yywrap() { return 1; }