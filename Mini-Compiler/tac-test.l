%{
#include "tac.tab.h"
%}

digit   [0-9]+
id      [a-zA-Z_][a-zA-Z0-9_]*

%%

"int"       { return INT; }
"if"        { return IF; }
"else"      { return ELSE; }

">="        { return GE; }
"="         { return ASSIGN; }
";"         { return SEMICOLON; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"+"         { return PLUS; }
"*"         { return MUL; }

{digit}     { yylval.num = atoi(yytext); return NUM; }
{id}        { yylval.id = strdup(yytext); return ID; }

[ \t\n]+    { /* ignore whitespace */ }

.           { return yytext[0]; }

%%
