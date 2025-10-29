%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int temp_reg = 0;

char* get_reg(char *var) {
    static char buf[10];
    if (isdigit(var[0]))
        sprintf(buf, "#%s", var);   // immediate constant
    else
        sprintf(buf, "r%d", temp_reg++); // assign new register
    return buf;
}
%}

%%
[ \t]+                 ;  /* ignore spaces */
[a-zA-Z_][a-zA-Z0-9_]*[ \t]*=[ \t]*[0-9]+      {
                            char lhs[32], rhs[32];
                            sscanf(yytext, "%s = %s", lhs, rhs);
                            printf("MOV %s, #%s\n", lhs, rhs);
                        }

[a-zA-Z_][a-zA-Z0-9_]*[ \t]*=[ \t]*[a-zA-Z0-9_]+[ \t]*[\+\-\*/][ \t]*[a-zA-Z0-9_]+ {
                            char lhs[32], op1[32], op2[32], op;
                            sscanf(yytext, "%s = %s %c %s", lhs, op1, &op, op2);
                            switch(op) {
                                case '+': printf("ADD %s, %s, %s\n", lhs, op1, op2); break;
                                case '-': printf("SUB %s, %s, %s\n", lhs, op1, op2); break;
                                case '*': printf("MUL %s, %s, %s\n", lhs, op1, op2); break;
                                case '/': printf("SDIV %s, %s, %s\n", lhs, op1, op2); break;
                            }
                        }

.|\n                    ;  /* ignore other chars */
%%

int yywrap() {
    return 1;
}

int main(void) {
    yylex();
    return 0;
}
