%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast/ast.h" /* Arvore Sintatica */
#include "tabSimb.h" /* Tabela de simbolos */

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
        printf("Ja existe uma variavel chamada %s.\n", nome_simb);
    }
    return;
}

/* Verifica se o simbolo existe na tabela. */
void context_check(char* nome_simb){
    if (inTab(tabela, nome_simb) == 0){
        printf("Nao foi declarada uma variavel chamada %s.\n", nome_simb);
    }
    return;
}

/* Verifica se o simbolo existe na tabela e, se existir, marca ele como usado. */
void context_check_and_mark(char* nome_simb){
    elemTab* endereco;
    if (getElem(tabela, nome_simb, &endereco) == 0){
        printf("Nao foi declarada uma variavel chamada %s.\n", nome_simb);
        return;
    }
    endereco -> usado = 1;
    return;
}

/* Verifca se o simbolo existe na tabela e se ele foi usado. */
void context_check_used(char* nome_simb){
    elemTab* endereco;
    if (getElem(tabela, nome_simb, &endereco) == 0){
        printf("Nao foi declarada uma variavel chamada %s.\n", nome_simb);
        return;
    }
    if (!(endereco -> usado)) printf("Nao foi atribuido valor para a variavel %s.\n", nome_simb);
    return;
}

extern int yylex();
extern int yylineno;
astNo* astTree;

int yyerror(const char* s);
%}

%union {
    struct astNo* ast_no;
    int intval;
    char* id;
}

%type <ast_no> program declarations id_seq commands command exp
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
        astTree = astCreateNo(PROGRAM_K, NULL, NULL, 0);
        astNo* children[] = { $2, $4 };
        astPutChild(astTree, children, 2);
    }
;

declarations:
    %empty {
        $$ = NULL;
    }
    | INTEGER id_seq IDENTIFIER '.' {
        // Create declarations node
        struct astNo* decl = astCreateNo(DECLARATIONS_K, NULL, NULL, 0);

        // Add last IDENTIFIER and id_seq on children
        struct astNo* last_id = astCreateTerminal(VAR_K, $3, NULL, 0, yylineno);
        astNo* children[] = { $2, last_id };
        astPutChild(decl, children, 2);

        $$ = decl;
        install( $3 ); /* Coloca IDENTIFIER na tabela de simbolos. */
    }
;

id_seq:
    %empty {
        $$ = NULL;
    }
    | id_seq IDENTIFIER ',' {
        struct astNo* id_node = astCreateTerminal(VAR_K, $2, NULL, 0, yylineno);

        if ($1) {
            astPutSibling($1, &id_node, 1);
            $$ = $1;
        } else {
            $$ = id_node;
        }
        install( $2 ); /* Coloca IDENTIFIER na tabela de simbolos. */
    }
;


commands:
    %empty {
        $$ = NULL;
    }
    | commands command ';' {
        astPutSibling($1, &($2), 1);
        $$ = $1;
    }
    | command ';' {
        $$ = $1;
    }
;

command:
    SKIP {
        $$ = astCreateNo(SKIP_K, NULL, NULL, 0);
    }
    | READ IDENTIFIER {
        $$ = astCreateNo(READ_K, $2, NULL, 0);
        context_check_and_mark( $2 ); /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        
    }
    | WRITE exp {
        $$ = astCreateNo(WRITE_K, NULL, NULL, 0);
        astPutChild($$, &($2), 1);
    }
    | IDENTIFIER ASSGNOP exp {
        $$ = astCreateNo(ASSIGN_K, $1, NULL, 0);
        astPutChild($$, &($3), 1);
        context_check_and_mark($1); /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        
    }
    | IF exp THEN commands ELSE commands FI {
        $$ = astCreateNo(IF_K, NULL, NULL, 0);
        astNo* children[] = { $2, $4, $6 };
        astPutChild($$, children, 3);
    }
    | WHILE exp DO commands END {
        $$ = astCreateNo(WHILE_K, NULL, NULL, 0);
        astNo* children[] = { $2, $4 };
        astPutChild($$, children, 2);
    }
;
exp:
    NUMBER {
        char buffer[12];
        sprintf(buffer, "%d", $1);
        char* num_str = strdup(buffer);
        $$ = astCreateTerminal(NUM_K, num_str, NULL, 0, yylineno);
    }
    | IDENTIFIER {
        $$ = astCreateTerminal(VAR_K, $1, NULL, 0, yylineno);
        context_check_used($1); /* Verifica se IDENTIFIER esta na tabela de simbolos e se teve atribuicao. */
    }
    | exp '<' exp {
        $$ = astCreateNo(LESS_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | exp '>' exp {
        $$ = astCreateNo(GREATER_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | exp '+' exp {
        $$ = astCreateNo(PLUS_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | exp '-' exp {
        $$ = astCreateNo(MINUS_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | exp '*' exp {
        $$ = astCreateNo(MULT_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | exp '/' exp {
        $$ = astCreateNo(DIV_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | exp '^' exp {
        $$ = astCreateNo(EXP_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
    }
    | '-' exp %prec UMINUS {
        $$ = astCreateNo(UMINUS_K, NULL, NULL, 0);
        astPutChild($$, &($2), 1);
    }
    | '(' exp ')' {
        $$ = $2;
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

int yyerror(const char* s) {
	fprintf(stderr, "Erro encontrado na analise sintatica\n  Linha do erro: %d\n  Descricao do erro: %s\n", yylineno, s);
        return 0;
}
