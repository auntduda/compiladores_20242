%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabSimb.h" /* Tabela de simbolos */
#include "ast/sm.h"
#include "ast/gc.h"

/* Lista de tipos de variaveis. */
#define INT 0

/* Declaracao da tabela de simbolos. 
tabSimb tabela;
*/

/* Contador de erros. */
unsigned int erros = 0;

// Relatorio de erros
void report_errors() {
    if (!erros)
        printf("Nenhum erro encontrado\n");

    else
    {
        printf("%d erro(s) encontrado(s)\n", erros);
        exit(1);
    }
}

typedef struct lbs {
    int for_goto;
    int for_jmp_false;
    struct lbs* next;
} lbs;

// Inicializa a lista de labels
lbs* lbs_list = NULL;

typedef struct str {
    char* string;
    struct str* next;
} str;

// Inicializa a lista de strings
str* str_list = NULL;

// Aloca espaço para as labels
struct lbs* create_label() {
    lbs* ptr = (struct lbs *) malloc(sizeof(struct lbs));
    ptr->next = lbs_list;
    lbs_list = ptr;
    
    return ptr;
}

// Esvazia a lista de labels
void clear_label_list(lbs* ptr) {
    if (ptr == NULL) return;

    clear_label_list(ptr->next);
    free(ptr);
}

void clear_yyval_list(str* ptr) {
    if (ptr == NULL) return;

    clear_yyval_list(ptr->next);
    free(ptr);
}

/* Rotina que instala um identificador na tabela de simbolos. */
void install (char* nome_simb){
    elemTab* s;
    s = getSimb(nome_simb);
    if (s == 0) s = inSimb(nome_simb);
    else {
        erros++;
        printf(YLW "Erro: variavel '%s' ja esta definida\n" RESET, nome_simb);
        report_errors();
    }
}

/* Verifica se o simbolo existe na tabela. */
void context_check(enum code_ops operation, char* simb){
    elemTab* identifier = getSimb(simb);
    if (identifier == 0) {
        erros++;
        printf(YLW "Erro: variavel '%s' nao foi declarada\n" RESET, simb);
        report_errors();
    }
    else gen_code(operation, identifier->offset);
}


int yyerror(const char* s);
extern int yylex();
extern int yylineno;
%}

%union {
    int intval;
    char* id;       
    struct lbs* lbls;
}


%define parse.error detailed

%start program
%token <id> ASSGNOP
%token DO
%token ELSE
%token END
%token <lbls> IF WHILE FI
%token IN 
%token INTEGER 
%token LET
%token READ
%token SKIP
%token THEN
%token WRITE
%token <id> IDENTIFIER
%token <intval> NUMBER
%left '<' '>' '='
%left '-' '+'
%left '*' '/'
%right '^'
%left UMINUS

%nonassoc IFX
%nonassoc ELSE

%%

program:
    LET
        declarations
    IN                      {gen_code(DATA, symTab->offset);}
        commands
    END {
        printf("Programa sintaticamente correto!\n");
        
        gen_code(HALT, 0); 
        fetch_execute_cycle();
        clearTable(symTab); 
        clear_label_list(lbs_list);
        clear_yyval_list(str_list);
        report_errors();
        YYACCEPT;
        printf("depois do halt\n");
    }
;

declarations:
    %empty {
        install("0");
    }
    | declarations INTEGER id_seq IDENTIFIER ';' {
        
        install( $4 ); /* Coloca IDENTIFIER na tabela de simbolos. */
    }
;

id_seq:
    %empty {
        /*
        $$ = NULL;
        */
    }
    | id_seq IDENTIFIER ',' {
        install( $2 ); /* Coloca IDENTIFIER na tabela de simbolos. */
    }
;


commands:
    %empty {
        /*
        $$ = NULL;
        */
    }
    | commands command ';' {
        /*
        $$ = $1;
        */
    }
;

command:
    SKIP {
        /*
        $$ = NULL;
        */
    }
    | READ IDENTIFIER {
        context_check( READ_INT, $2 ); /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
    }
    | WRITE exp {
        gen_code(WRITE_INT, 0);

    }
    | IDENTIFIER ASSGNOP exp {
        /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        context_check(STORE, $1);
    }
    | IF exp                        {$1 = (struct lbs *) create_label(); $1->for_jmp_false = reserve_loc();}
        THEN commands               {$1->for_goto = reserve_loc();}
      ELSE                          {back_patch($1->for_jmp_false, JMP_FALSE, gen_label());}
        commands
      FI                            {back_patch($1->for_goto, GOTO, gen_label());}

    | WHILE                         {$1 = (lbs *) create_label(); $1->for_goto = gen_label();}
        exp                         {$1->for_jmp_false = reserve_loc();}
      DO
        commands
      END                           {gen_code(GOTO, $1->for_goto); 
                                            back_patch($1->for_jmp_false, JMP_FALSE, gen_label());}
;
exp:
    NUMBER {
        gen_code(LD_INT, $1);

    }
    | IDENTIFIER {
        context_check(LD_VAR, $1); /* Verifica se IDENTIFIER esta na tabela de simbolos e se teve atribuicao. */
        
    }
    | exp '<' exp {
        gen_code(LT, 0);

    }
    | exp '>' exp {
        gen_code(GT, 0);

    }
    | exp '+' exp {
        gen_code(ADD, 0);
        
    }
    | exp '-' exp {
        gen_code(SUB, 0);

    }
    | exp '*' exp {
        gen_code(MULT, 0);

    }
    | exp '/' exp {
        gen_code(DIV, 0);

    }
    | exp '^' exp {
        gen_code(PWR, 0);

    }
    | '-' exp %prec UMINUS {
        gen_code(NEG, 0);

    }
    | '(' exp ')' {
        /*
        $$ = $2;
        */
    }
;

%%

int main(int argc, char *argv[]) {
    //tabela = criaTabela(); /* Criacao da tabela de simbolos */
    extern FILE *yyin;
    ++argv; --argc;
    yyin = fopen(argv[0], "r");
    //yydebug = 1;
    printf("Analisando arquivo '%s'...\n", argv[0]);
    yyparse();

    if (erros > 0) printf("Compilacao concluida com erros.\n");

    /*
    else {
        // Imprime as variaveis da tabela
        printf("\n");
        printTab(tabela);
        printf("\n");

        // Imprime as variaveis que nao foram usadas.
        naoUsado(tabela);
        printf("\n");
        
        return 0;
    }
    */
}

int yyerror(const char* s) {
	fprintf(stderr, "Erro encontrado na analise sintatica\n  Linha do erro: %d\n  Descricao do erro: %s\n", yylineno, s);
        return 0;
}
