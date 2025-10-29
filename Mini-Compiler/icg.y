%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int temp_count = 0;
int label_count = 0;

char* newTemp() {
    char *t = malloc(10);
    sprintf(t, "t%d", temp_count++);
    return t;
}

char* newLabel() {
    char *l = malloc(10);
    sprintf(l, "L%d", label_count++);
    return l;
}

void emit(const char *s) {
    printf("%s\n", s);
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
%token IF ELSE INT
%token ADD SUB MUL DIV ASSIGN
%token GE LE EQ NE GT LT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON

%left ADD SUB
%left MUL DIV
%left GT LT GE LE EQ NE

%type <code> expr condition statement statements

%%

program:
    statements
;

statements:
    statements statement
    | statement
;

statement:
      INT ID ASSIGN expr SEMICOLON {
          char buf[100];
          sprintf(buf, "%s = %s", $2, $4);
          emit(buf);
      }
    | ID ASSIGN expr SEMICOLON {
          char buf[100];
          sprintf(buf, "%s = %s", $1, $3);
          emit(buf);
      }
    | IF LPAREN condition RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE {
          char *L1 = newLabel();
          char *L2 = newLabel();
          emit($3);
          printf("ifFalse %s goto %s\n", $3, L1);
          printf("%s:\n", L1);
          emit($6);
          printf("goto %s\n", L2);
          printf("%s:\n", L2);
          emit($10);
      }
    | IF LPAREN condition RPAREN LBRACE statements RBRACE {
          char *L1 = newLabel();
          emit($3);
          printf("ifFalse %s goto %s\n", $3, L1);
          emit($6);
          printf("%s:\n", L1);
      }
    | /* empty */
;

expr:
      expr ADD expr {
          char *t = newTemp();
          char buf[100];
          sprintf(buf, "%s = %s + %s", t, $1, $3);
          emit(buf);
          $$ = t;
      }
    | expr SUB expr {
          char *t = newTemp();
          char buf[100];
          sprintf(buf, "%s = %s - %s", t, $1, $3);
          emit(buf);
          $$ = t;
      }
    | expr MUL expr {
          char *t = newTemp();
          char buf[100];
          sprintf(buf, "%s = %s * %s", t, $1, $3);
          emit(buf);
          $$ = t;
      }
    | expr DIV expr {
          char *t = newTemp();
          char buf[100];
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

condition:
      expr GT expr {
          char *t = newTemp();
          char buf[100];
          sprintf(buf, "%s > %s", $1, $3);
          $$ = strdup(buf);
      }
    | expr LT expr {
          char *t = newTemp();
          char buf[100];
          sprintf(buf, "%s < %s", $1, $3);
          $$ = strdup(buf);
      }
    | expr GE expr {
          char buf[100];
          sprintf(buf, "%s >= %s", $1, $3);
          $$ = strdup(buf);
      }
    | expr LE expr {
          char buf[100];
          sprintf(buf, "%s <= %s", $1, $3);
          $$ = strdup(buf);
      }
    | expr EQ expr {
          char buf[100];
          sprintf(buf, "%s == %s", $1, $3);
          $$ = strdup(buf);
      }
    | expr NE expr {
          char buf[100];
          sprintf(buf, "%s != %s", $1, $3);
          $$ = strdup(buf);
      }
;

%%

int main() {
    yyparse();
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
    return 0;
}
