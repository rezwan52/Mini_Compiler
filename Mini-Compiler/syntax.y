%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int lineno;
void yyerror(const char *s);
%}

/* ---------- TOKEN DEFINITIONS ---------- */
%union {
    char *sval;
    float fval;
}

%token TYPE
%token <sval> ID
%token <fval> NUMBER
%token ASSIGN SEMI
%token LPAREN RPAREN LBRACE RBRACE
%token PLUS MINUS MUL DIV

/* ---------- OPERATOR PRECEDENCE ---------- */
%left PLUS MINUS
%left MUL DIV

%start program

%%

/* ---------- GRAMMAR RULES ---------- */

program:
      stmt_list
    ;

stmt_list:
      stmt_list stmt
    | stmt
    | error SEMI { yyerror("Syntax error recovered"); yyerrok; }
    ;

stmt:
      declaration
    | assign_stmt
    ;

declaration:
      TYPE ID SEMI {
            printf("[Line %d] → Declaration: %s\n", lineno, $2);
      }
    ;

assign_stmt:
      ID ASSIGN expr SEMI {
            printf("[Line %d] → Assignment: %s = ...\n", lineno, $1);
      }
    ;

expr:
      expr PLUS expr
    | expr MINUS expr
    | expr MUL expr
    | expr DIV expr
    | LPAREN expr RPAREN
    | ID
    | NUMBER
    ;

%%

/* ---------- ERROR HANDLER ---------- */
void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax error at line %d: %s\n", lineno, s);
}

/* ---------- MAIN ---------- */
int main(void) {
    printf("=== Starting Syntax Analysis ===\n\n");
    yyparse();
    printf("\n=== Parsing Complete ===\n");
    return 0;
}
