%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast/ast.h" /* Arvore Sintatica */
#include "tabSimb.h" /* Tabela de simbolos */
#include "otimizador/otimizador.h" /* Otimizador */

/* Lista de tipos de variaveis. */
#define INT 0

/* Declaracao da tabela de simbolos. */
tabSimb tabela;

/* Contador de erros. */
unsigned int erros = 0;

/* Rotina que instala um identificador na tabela de simbolos. */
void install (char* nome_simb){
    /* Chama a funcao que coloca um novo elemento na tabela. Se a funcao retornar 1, significa que um elemento com esse nome ja exisitia, o que ativara um erro. Se o retorno for 0, o elemento foi colocado na tabela de simbolos. */
    if (pushElem(&tabela, nome_simb, INT)) {
        erros++;
        printf("ERRO: Ja existe uma variavel chamada %s.\n", nome_simb);
    }
    return;
}

/* Verifica se o simbolo existe na tabela. */
void context_check(char* nome_simb){
    if (inTab(tabela, nome_simb) == 0){
        erros++;
        printf("ERRO: Nao foi declarada uma variavel chamada %s.\n", nome_simb);
    }
    return;
}

/* Verifica se o simbolo existe na tabela e, se existir, marca ele como usado. */
void context_check_and_mark(char* nome_simb){
    elemTab* endereco;
    if (getElem(tabela, nome_simb, &endereco) == 0){
        erros++;
        printf("ERRO: Nao foi declarada uma variavel chamada %s.\n", nome_simb);
        return;
    }
    endereco -> usado = 1;
    return;
}
/* Verifica se o simbolo existe na tabela, se sim adiciona a sua contagem 10 vezes a quantidade de vezes que aparece no loop */
void loop_count(char* exp, char* commands, tabSimb tabela){
    if(expressionProcessing(exp, tabela) == 0){
        printf("Nenhuma variável encontrada na expressão\n");
    }
    if(commandsProcessing(commands, tabela) == 0){
        printf("Nenhuma variável encontrada nos comandos\n");
    }

    return;
}

/* Verifca se o simbolo existe na tabela e se ele foi usado. */
void context_check_used(char* nome_simb){
    elemTab* endereco;
    if (getElem(tabela, nome_simb, &endereco) == 0){
        erros++;
        printf("ERRO: Nao foi declarada uma variavel chamada %s.\n", nome_simb);
        return;
    }
    if (!(endereco -> usado)) {
        erros++;
        printf("ERRO: Nao foi atribuido valor para a variavel %s.\n", nome_simb);
        }
    return;
}



extern int yylex();
extern int yylineno;
astNo* astTree;
char** variaveisLoop;
int tamanhoVariaveisLoop = 0;

int yyerror(const char* s);
%}

%union {
    struct astNo* ast_no;
    int intval;
    char* id;
    char* command;
}

%type <command> program declarations id_seq commands command exp
%token <id> IDENTIFIER
%token <intval> NUMBER

%nonassoc IFX
%nonassoc ELSE

%start program

%token <int> LET INTEGER IN SKIP IF THEN ELSE FI END WHILE DO READ WRITE ASSGNOP
%left '<' '>' '='
%left '-' '+'
%left '*' '/'
%right '^'
%left UMINUS

%define parse.error detailed

%%

program:
    LET declarations IN commands END {
        printf("Programa sintaticamente correto!\n");
    }
;

declarations:
    %empty {
        $$ = NULL;
    }
    | INTEGER id_seq IDENTIFIER '.' {
        install( $3 ); /* Coloca IDENTIFIER na tabela de simbolos. */
    }
;

id_seq:
    %empty {
        $$ = NULL;
    }
    | id_seq IDENTIFIER ',' {
        install( $2 ); /* Coloca IDENTIFIER na tabela de simbolos. */
    }
;


commands:
    %empty {
        $$ = strdup("");  // Inicializa como string vazia
    }
    | commands command ';' {
        $$ = concatStr(3, $1, $2, ";");  // Concatena as strings
    }
    | command ';' {
        $$ = concatStr(2, $1, ";");
    }
;

command:
    SKIP {
        $$ = strdup("SKIP");
        /* Construindo Strings para todos os comandos que podem vir dentro do while */
    }
    | READ IDENTIFIER {
        $$ = concatStr(2, "READ ", $2);
        context_check_and_mark($2); /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        
    }
    | WRITE exp {
        $$ = concatStr(2, "WRITE ", $2);
    }
    | IDENTIFIER ASSGNOP exp {
        $$ = concatStr(3, $1, " = ", $3);
        context_check_and_mark($1);/* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        
    }
    | IF exp THEN commands ELSE commands FI {
        $$ = concatStr(7, "IF ", $2, " THEN ", $4, " ELSE ", $6, " FI");
    }
    | WHILE exp DO commands END {
        $$ = concatStr(5, "WHILE ", $2, " DO ", $4, " END");
        printf("Expressao: %s\n", $2);
        printf("Comandos: %s\n", $4);
        loop_count($2, $4, tabela);
    }
;
exp:
    NUMBER {
        char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    | IDENTIFIER {
        $$ = strdup($1);
        context_check_used($1); /* Verifica se IDENTIFIER esta na tabela de simbolos e se teve atribuicao. */
    }
    | exp '<' exp {
        $$ = concatStr(3, $1, " < ", $3);
    }
    | exp '>' exp {
        $$ = concatStr(3, $1, " > ", $3);
    }
    | exp '+' exp {
        $$ = concatStr(3, $1, " + ", $3);
    }
    | exp '-' exp {
        $$ = concatStr(3, $1, " - ", $3);
    }
    | exp '*' exp {
        $$ = concatStr(3, $1, " * ", $3);
    }
    | exp '/' exp {
        $$ = concatStr(3, $1, " / ", $3);
    }
    | exp '^' exp {
        $$ = concatStr(3, $1, " ^ ", $3);
    }
    | '-' exp %prec UMINUS {
        $$ = concatStr(2, "-", $2);
    }
    | '(' exp ')' {
        $$ = concatStr(3, "( ", $2, " )");
    }
;

%%

int main(int argc, char *argv[]) {
    tabela = criaTabela(); /* Criacao da tabela de simbolos */
    extern FILE *yyin;
    ++argv; --argc;
    yyin = fopen(argv[0], "r");
    //yydebug = 1;
    printf("Analisando arquivo '%s'...\n", argv[0]);
    yyparse();

    if (erros > 0) printf("Compilacao concluida com erros.\n");

    else {
        /* Imprime as variaveis da tabela */
        printf("\n");
        printTab(tabela);
        printf("\n");

        /* Imprime as variaveis que nao foram usadas. */
        naoUsado(tabela);
        printf("\n");

        if(astTree){
            printf("Arvore Sintatica: \n");
            astPrint(astTree);
            astDeepFree(astTree);
        }
        
        return 0;
    }
}

int yyerror(const char* s) {
	fprintf(stderr, "Erro encontrado na analise sintatica\n  Linha do erro: %d\n  Descricao do erro: %s\n", yylineno, s);
        return 0;
}
