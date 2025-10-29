%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int temp_count = 0;
int label_count = 0;

char* newTemp() {
    char *t = malloc(5);
    sprintf(t, "t%d", temp_count++);
    return t;
}

char* newLabel() {
    char *l = malloc(5);
    sprintf(l, "L%d", label_count++);
    return l;
}

void gen(char *code) {
    printf("%s\n", code);
}

%}

%union {
    int num;
    char* id;
    char* code;
}

%token INT IF ELSE
%token ID NUM
%token GE ASSIGN SEMICOLON LPAREN RPAREN LBRACE RBRACE PLUS MUL

%type <code> stmt expr term factor

%%

program:
    decls stmts
;

decls:
    /* empty */
;

stmts:
    stmt stmts
    | /* empty */
;

stmt:
    ID ASSIGN expr SEMICOLON {
        char tmp[100];
        sprintf(tmp, "%s = %s", $1, $3);
        gen(tmp);
    }
    | IF LPAREN expr GE expr RPAREN LBRACE stmts RBRACE {
        char *l1 = newLabel();
        char *l2 = newLabel();
        char tmp[100];
        sprintf(tmp, "if %s < %s goto %s", $3, $5, l1);
        gen(tmp);
        // statements inside if
        gen("..."); // statements already generated
        sprintf(tmp, "goto %s", l2);
        gen(tmp);
        gen(l1);
        gen("..."); // else part if exists
        gen(l2);
    }
    | LBRACE stmts RBRACE
;

expr:
    expr PLUS term {
        char* t = newTemp();
        char tmp[100];
        sprintf(tmp, "%s = %s + %s", t, $1, $3);
        $$ = t;
        gen(tmp);
    }
    | term { $$ = $1; }
;

term:
    term MUL factor {
        char* t = newTemp();
        char tmp[100];
        sprintf(tmp, "%s = %s * %s", t, $1, $3);
        $$ = t;
        gen(tmp);
    }
    | factor { $$ = $1; }
;

factor:
    NUM {
        char* t = newTemp();
        char tmp[100];
        sprintf(tmp, "%s = %d", t, $1);
        $$ = t;
        gen(tmp);
    }
    | ID { $$ = $1; }
;

%%

int main() {
    yyparse();
    return 0;
}

int yyerror(char *s) {
    printf("Parse error: %s\n", s);
    return 0;
}
