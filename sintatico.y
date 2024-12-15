%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
%}

%start program
%token LET INTEGER IN
%token SKIP IF THEN ELSE FI END WHILE DO READ WRITE
%token ASSGNOP
%token NUMBER
%token IDENTIFIER
%left '<' '>' '='
%left '-' '+'
%left '*' '/'
%right '^'
%left UMINUS

%define parse.error detailed

%%

program: LET declarations IN commands END { printf ("Programa sintaticamente correto!\n"); } ;

declarations: /* empty */
        | INTEGER id_seq IDENTIFIER '.'
;

id_seq: /* empty */
        | id_seq IDENTIFIER ','
;

commands: /* empty */
        | commands command ';'
;

command: SKIP
        | READ IDENTIFIER
        | WRITE exp
        | IDENTIFIER ASSGNOP exp
        | IF exp THEN commands ELSE commands FI
        | WHILE exp DO commands END
;

exp: NUMBER
        | IDENTIFIER
        | exp '<' exp
        | exp '=' exp
        | exp '>' exp
        | exp '+' exp
        | exp '-' exp
        | exp '*' exp
        | exp '/' exp
        | exp '^' exp
        | '-' exp %prec UMINUS
        | '(' exp ')'
;

%%

int main(int argc, char *argv[]) {
    extern FILE *yyin;
    ++argv; --argc;
    yyin = fopen(argv[0], "r");
    //yydebug = 1;
    printf("Analisando arquivo '%s'...\n", argv[0]);
    yyparse();
    return 0;
}

yyerror(char* s) {
	fprintf(stderr, "Erro encontrado na analise sintatica\n  Linha do erro: %d\n  Descricao do erro: %s\n", yylineno, s);
}
