%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int lineno;
void yyerror(const char *s);
%}

%union {
    char *sval;
    float fval;
}

%token TYPE
%token <sval> ID
%token <fval> NUMBER
%token ASSIGN SEMI OP LPAREN RPAREN LBRACE RBRACE

%start program

%%

program:
      stmt_list
    ;

stmt_list:
      stmt_list stmt
    | stmt
    ;

stmt:
      declaration
    | assign_stmt
    ;

declaration:
      TYPE ID SEMI {
            printf("→ Declaration statement found at line %d: %s\n", lineno, $2);
      }
    ;

assign_stmt:
      ID ASSIGN expr SEMI {
            printf("→ Assignment statement found at line %d: %s = ...\n", lineno, $1);
      }
    ;

expr:
      expr OP expr
    | LPAREN expr RPAREN
    | ID
    | NUMBER
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax error at line %d: syntax error\n", lineno);
}

int main(void) {
    printf("=== Starting Syntax Analysis ===\n\n");
    yyparse();
    printf("\n=== Parsing Complete ===\n");
    return 0;
}
