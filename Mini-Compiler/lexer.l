%{
    #include<stdio.h>
    int count = 0;
    #include "parser.tab.h"
%}

%option noyywrap

%%
[ \t\r] {}
"count" {printf("%d number of tokens", count);}
"//".* {printf("%s --> Single line Comment\n", yytext); count++;}
"int"|"float"|"return"|"if"|"else"|"auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"enum"|"extern"|"for"|"goto"|"long"|"register"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while" {printf("%s --> KEYWORD\n", yytext); count++;}
"+"|"-"|"*"|"/" {printf("%s --> Arithmetic Operator\n", yytext); count++;}
";"|":"|"," {printf("%s --> Punctuation Sign\n", yytext); count++;}
"=" {printf("%s --> Assign Operator\n", yytext); count++;}
"("|"[" {printf("%s --> Left Parenthesis\n", yytext); count++;}
")"|"]" {printf("%s --> Right Parenthesis\n", yytext); count++;}
"{" {printf("%s --> Left Curly Braces\n", yytext); count++;}
"}" {printf("%s --> Right Curly Braces\n", yytext); count++;}
"=="|"!="|">="|">"|"<"|"<=" {printf("%s --> Logical Operator\n", yytext); count++;}
[0-9]+ {printf("%s --> CONSTANT\n", yytext); count++;}
^01[73][0-9]{8}$ {printf("%s --> GrameenPhone Number\n", yytext); count++;}
^01[9][0-9]{8}$ {printf("%s --> Banglalink Phone Number\n", yytext); count++;}
^01[8][0-9]{8}$ {printf("%s --> Robi Phone Number\n", yytext); count++;}
[a-zA-Z_][a-zA-z_0-9]* {printf("%s --> IDENTIFIER\n", yytext); count++;}

. {printf("typed a character\n"); count++;}
%%

int main(){

  yylex();
  return 0;
}