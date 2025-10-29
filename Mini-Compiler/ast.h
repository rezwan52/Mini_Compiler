// ast.h
#ifndef AST_H
#define AST_H

typedef struct Node {
    char *val;
    struct Node *left;
    struct Node *right;
} Node;

/* Function declarations */
Node* createNode(char *val, Node *left, Node *right);
void printAST(Node* root, int level);

#endif
