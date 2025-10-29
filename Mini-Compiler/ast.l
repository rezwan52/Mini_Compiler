%{
#include "y.tab.h"
int lineno = 1;
%}

%%

"int"|"float"|"double"|"char"|"bool"   { yylval.str = strdup(yytext); return TYPE; }
[a-zA-Z_][a-zA-Z0-9_]*                 { yylval.str = strdup(yytext); return ID; }
[0-9]+(\.[0-9]+)?                      { yylval.str = strdup(yytext); return NUMBER; }
"="                                     { return ASSIGN; }
";"                                     { return SEMI; }
"+"|"-"|"*"|"/"                         { yylval.str = strdup(yytext); return OP; }
[ \t]+                                  ; // ignore spaces
\n                                      { lineno++; }
.                                       { return UNKNOWN; }

%%
