%{
#include "icg.tab.h"
#include <stdlib.h>
#include <string.h>
%}

digit   [0-9]
id      [a-zA-Z_][a-zA-Z0-9_]*

%%

"if"            { return IF; }
"else"          { return ELSE; }
"int"           { return INT; }

">="            { return GE; }
"<="            { return LE; }
"=="            { return EQ; }
"!="            { return NE; }
">"             { return GT; }
"<"             { return LT; }

"="             { return ASSIGN; }
"+"             { return ADD; }
"-"             { return SUB; }
"*"             { return MUL; }
"/"             { return DIV; }

";"             { return SEMICOLON; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"("             { return LPAREN; }
")"             { return RPAREN; }

{digit}+        { yylval.num = atoi(yytext); return NUMBER; }
{id}            { yylval.id = strdup(yytext); return ID; }

[ \t\r\n]+      { /* skip whitespace */ }
.               { return yytext[0]; }

%%

int yywrap() { return 1; }
