%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int temp_count = 0;

char* newTemp() {
    char *t = malloc(5);
    sprintf(t, "t%d", temp_count++);
    return t;
}

void emit(char *code) {
    printf("%s\n", code);  // terminal output
}

int yylex();
int yyerror(char *s);
%}

%union {
    int num;
    char *id;
    char *code;
}

%token <num> NUMBER
%token <id> ID
%token ASSIGN ADD SUB MUL DIV SEMICOLON

%left ADD SUB
%left MUL DIV

%type <code> expr statement

%%

program:
    statements
;

statements:
    statements statement
    | statement
;

statement:
    ID ASSIGN expr SEMICOLON {
        char buf[50];
        sprintf(buf, "%s = %s", $1, $3);
        emit(buf);
    }
;

expr:
    expr ADD expr {
        char *t = newTemp();
        char buf[50];
        sprintf(buf, "%s = %s + %s", t, $1, $3);
        emit(buf);
        $$ = t;
    }
    | expr SUB expr {
        char *t = newTemp();
        char buf[50];
        sprintf(buf, "%s = %s - %s", t, $1, $3);
        emit(buf);
        $$ = t;
    }
    | expr MUL expr {
        char *t = newTemp();
        char buf[50];
        sprintf(buf, "%s = %s * %s", t, $1, $3);
        emit(buf);
        $$ = t;
    }
    | expr DIV expr {
        char *t = newTemp();
        char buf[50];
        sprintf(buf, "%s = %s / %s", t, $1, $3);
        emit(buf);
        $$ = t;
    }
    | NUMBER {
        char *t = malloc(10);
        sprintf(t, "%d", $1);
        $$ = t;
    }
    | ID {
        $$ = $1;
    }
;

%%

int main(int argc, char **argv) {
    yyparse();  // generate ICG to terminal
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
    return 0;
}