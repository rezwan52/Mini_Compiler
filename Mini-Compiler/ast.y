%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lineno;
void yyerror(const char *s);
int yylex(void);

/* Node struct for AST */
typedef struct Node {
    char *val;
    struct Node *left;
    struct Node *right;
} Node;

/* Create a new AST node */
Node* createNode(char *val, Node *left, Node *right) {
    Node *n = (Node*) malloc(sizeof(Node));
    n->val = strdup(val);
    n->left = left;
    n->right = right;
    return n;
}

/* Print AST recursively */
void printAST(Node *root, int level) {
    if (!root) return;
    for(int i=0;i<level;i++) printf("  ");
    printf("%s\n", root->val);
    printAST(root->left, level+1);
    printAST(root->right, level+1);
}

%}

%union {
    char *str;
    Node *node;
}

%token <str> TYPE ID NUMBER OP
%token ASSIGN SEMI
%token UNKNOWN
%type <node> expr assignment

%%

program:
    | program statement
    ;

statement:
      assignment
    ;

assignment:
    ID ASSIGN expr SEMI
    {
        Node *tree = createNode("=", createNode($1,NULL,NULL), $3);
        printf("→ Assignment statement at line %d: %s = ...\n", lineno, $1);
        printAST(tree, 0);
        printf("\n");
    }
    ;

expr:
      NUMBER          { $$ = createNode($1, NULL, NULL); }
    | ID              { $$ = createNode($1, NULL, NULL); }
    | expr OP expr    { $$ = createNode($2, $1, $3); }
    ;

%%

void yyerror(const char *s) {
    printf("❌ Syntax error at line %d: %s\n", lineno, s);
}
