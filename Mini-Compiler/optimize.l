%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int is_number(const char *s) {
    for (int i = 0; s[i]; i++) {
        if (s[i] < '0' || s[i] > '9') return 0;
    }
    return 1;
}
%}

%%

[ \t]+                     ;   /* ignore spaces */


([a-zA-Z_][a-zA-Z0-9_]*)[ \t]*=[ \t]*([0-9]+)[ \t]*([\+\-\*/])[ \t]*([0-9]+)[ \t]*\n  {
    char var[32], op1[32], op2[32], op;
    sscanf(yytext, "%s = %s %c %s", var, op1, &op, op2);

    int v1 = atoi(op1), v2 = atoi(op2), res = 0;
    switch(op) {
        case '+': res = v1 + v2; break;
        case '-': res = v1 - v2; break;
        case '*': res = v1 * v2; break;
        case '/': if (v2 != 0) res = v1 / v2; break;
    }

    printf("%s = %d\n", var, res);
}


.|\n                      { ECHO; }

%%

int yywrap() { return 1; }

int main() {
    yylex();
    return 0;
}
