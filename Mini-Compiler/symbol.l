%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int line = 1;
int address = 1000;   // starting address

// ============================
// Symbol Table Entry
// ============================
struct Symbol {
    char token[50];
    char datatype[20];
    char value[20];
    int line;
    char dimension[10];
    int address;
    char tokentype[20];
};

struct Symbol symtab[100];
int sym_count = 0;

// ============================
// Helper functions
// ============================
void add_symbol(char *token, char *datatype, char *value, char *dimension, char *tokentype) {
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(symtab[i].token, token) == 0)
            return; // already exists
    }
    strcpy(symtab[sym_count].token, token);
    strcpy(symtab[sym_count].datatype, datatype);
    strcpy(symtab[sym_count].value, value);
    strcpy(symtab[sym_count].dimension, dimension);
    strcpy(symtab[sym_count].tokentype, tokentype);
    symtab[sym_count].line = line;
    symtab[sym_count].address = address;
    address += 4;
    sym_count++;
}

void print_symbol_table() {
    printf("\n================ SYMBOL TABLE ================\n");
    printf("%-10s %-10s %-10s %-8s %-10s %-10s %-12s\n",
           "Token", "DataType", "Value", "Line", "Dim", "Address", "TokenType");
    printf("---------------------------------------------------------------\n");
    for (int i = 0; i < sym_count; i++) {
        printf("%-10s %-10s %-10s %-8d %-10s %-10d %-12s\n",
               symtab[i].token,
               symtab[i].datatype,
               symtab[i].value,
               symtab[i].line,
               symtab[i].dimension,
               symtab[i].address,
               symtab[i].tokentype);
    }
    printf("===============================================================\n");
}
%}

%%
"int"           { add_symbol(yytext, "-", "-", "-", "KEYWORD"); }
"float"         { add_symbol(yytext, "-", "-", "-", "KEYWORD"); }
"char"          { add_symbol(yytext, "-", "-", "-", "KEYWORD"); }
"double"        { add_symbol(yytext, "-", "-", "-", "KEYWORD"); }

[a-zA-Z_][a-zA-Z0-9_]*   { add_symbol(yytext, "int", "-", "-", "IDENTIFIER"); }
[0-9]+                   { add_symbol(yytext, "-", yytext, "-", "CONSTANT"); }

"="             { add_symbol(yytext, "-", "-", "-", "OPERATOR"); }
";"             { add_symbol(yytext, "-", "-", "-", "DELIMITER"); }
"\\+"           { add_symbol(yytext, "-", "-", "-", "OPERATOR"); }
"-"             { add_symbol(yytext, "-", "-", "-", "OPERATOR"); }
"\\*"           { add_symbol(yytext, "-", "-", "-", "OPERATOR"); }
"/"             { add_symbol(yytext, "-", "-", "-", "OPERATOR"); }
"\\["           { add_symbol(yytext, "-", "-", "-", "BRACKET"); }
"\\]"           { add_symbol(yytext, "-", "-", "-", "BRACKET"); }
"\\("           { add_symbol(yytext, "-", "-", "-", "BRACKET"); }
"\\)"           { add_symbol(yytext, "-", "-", "-", "BRACKET"); }

\n              { line++; }
[ \t\r]+        ;
.               ;
%%

int yywrap() { return 1; }

int main() {
    yylex();
    print_symbol_table();
    return 0;
}
