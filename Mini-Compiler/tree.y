%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* AST Node structure */
typedef struct Node {
    char *val;           // Operator, identifier, or number
    struct Node *left;   // Left child
    struct Node *right;  // Right child
} Node;

/* Create a new AST node */
Node* createNode(char *val, Node *left, Node *right) {
    Node* n = (Node*) malloc(sizeof(Node));
    n->val = strdup(val);
    n->left = left;
    n->right = right;
    return n;
}

/* Print AST inorder with parentheses */
void printAST(Node* root) {
    if (!root) return;
    if(root->left || root->right) printf("(");
    printAST(root->left);
    printf("%s", root->val);
    printAST(root->right);
    if(root->left || root->right) printf(")");
}

extern int yylex();
extern int lineno;
void yyerror(const char *s);
%}

%union {
    char *sval;
    Node *nval;
}

%token TYPE
%token <sval> ID
%token <sval> NUMBER
%token ASSIGN SEMI OP LPAREN RPAREN LBRACE RBRACE

%type <nval> expr stmt

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
      TYPE ID SEMI {
          printf("Declaration: %s at line %d\n", $2, lineno);
      }
    | ID ASSIGN expr SEMI {
          printf("Assignment: %s = ", $1);
          printAST($3);
          printf("\n");
      }
    ;

expr:
      expr OP expr { $$ = createNode($2, $1, $3); }
    | LPAREN expr RPAREN { $$ = $2; }
    | ID { $$ = createNode($1, NULL, NULL); }
    | NUMBER { $$ = createNode($1, NULL, NULL); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax error at line %d: %s\n", lineno, s);
}

int main(void) {
    printf("=== AST Parser ===\n\n");
    yyparse();
    printf("\n=== Parsing Complete ===\n");
    return 0;
}
