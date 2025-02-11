%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast/ast.h" /* Arvore Sintatica */
#include "tabSimb.h" /* Tabela de simbolos */
#include "ast/sm.h"
#include "ast/gc.h"

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

astNo* astTree;

int yyerror(const char* s);
extern int yylex();
extern int yylineno;
%}

%union {
    struct astNo* ast_no;
    
    int intval;     
    float floatval;  
    char* id;       
    struct lbs* lbls;
}

%type <ast_no> program declarations id_seq commands command exp

%start program
%token <int> LET INTEGER IN SKIP IF THEN ELSE FI END WHILE DO READ WRITE ASSGNOP
%token <id> IDENTIFIER
%token <intval> NUMBER
%left '<' '>' '='
%left '-' '+'
%left '*' '/'
%right '^'
%left UMINUS

%nonassoc IFX
%nonassoc ELSE
%define parse.error detailed

%%

program:
    LET
        declarations
    IN                      {gen_code(DATA, (struct stack_t) {.intval = symTab->tamanho});}
        commands
    END {
        printf("Programa sintaticamente correto!\n");
        
        gen_code(HALT, (struct stack_t) {.intval =  0}); 
        fetch_execute_cycle();
        clear_table(TabSimb); 
        clear_label_list(lbs_list);
        clear_yyval_list(str_list);
        report_errors();
        YYACCEPT;

        /*
        astTree = astCreateNo(PROGRAM_K, NULL, NULL, 0);
        astNo* children[] = { $2, $4 };
        astPutChild(astTree, children, 2);
        */
    }
;

declarations:
    %empty {
        install("0");
        
        /*
        $$ = NULL;
        */
    }
    | declarations INTEGER id_seq IDENTIFIER ';' {
        
        install( $4 ); /* Coloca IDENTIFIER na tabela de simbolos. */
        
        /*
        // Create declarations node
        struct astNo* decl = astCreateNo(DECLARATIONS_K, NULL, NULL, 0);

        // Add last IDENTIFIER and id_seq on children
        struct astNo* last_id = astCreateTerminal(VAR_K, $3, NULL, 0, yylineno);
        astNo* children[] = { $2, last_id };
        astPutChild(decl, children, 2);
        
        $$ = decl;
        */
    }
;

id_seq:
    %empty {
        $$ = NULL;
    }
    | id_seq IDENTIFIER ',' {
        install( $2 ); /* Coloca IDENTIFIER na tabela de simbolos. */
        
        /*
        struct astNo* id_node = astCreateTerminal(VAR_K, $2, NULL, 0, yylineno);

        if ($1) {
            astPutSibling($1, &id_node, 1);
            $$ = $1;
        } else {
            $$ = id_node;
        }
        */
    }
;


commands:
    %empty {
        $$ = NULL;
    }
    | commands command ';' {
        $$ = $1;
        
        /*
        astPutSibling($1, &($2), 1);
        */
    }
    /*
    | command ';' {
        $$ = $1;
    }
    */
;

command:
    SKIP {
        $$ = NULL;
        
        /*
        $$ = astCreateNo(SKIP_K, NULL, NULL, 0);
        */
    }
    | READ IDENTIFIER {
        context_check_and_mark( $2 ); /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        
        /*
        $$ = astCreateNo(READ_K, $2, NULL, 0);
        */
    }
    | WRITE exp {
        gen_code(WRITE_INT, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(WRITE_K, NULL, NULL, 0);
        astPutChild($$, &($2), 1);
        */
    }
    | IDENTIFIER ASSGNOP exp {
        context_check_and_mark($1); /* Verifica se IDENTIFIER esta na tabela de simbolos e marca como usado. */
        
        /*
        $$ = astCreateNo(ASSIGN_K, $1, NULL, 0);
        astPutChild($$, &($3), 1);
        */
    }
    | IF exp                        {$1 = (struct lbs *) create_label(); $1->for_jmp_false = reserve_loc();}
        THEN commands               {$1->for_goto = reserve_loc();}
      ELSE                          {back_patch($1->for_jmp_false, JMP_FALSE, (struct stack_t) {.intval = gen_label()});}
        commands
      FI                            {back_patch($1->for_goto, GOTO, (struct stack_t) {.intval = gen_label()});}

    /*
    {$$ = astCreateNo(IF_K, NULL, NULL, 0);astNo* children[] = { $2, $4, $6 };astPutChild($$, children, 3);}
    */

    | WHILE                         {$1 = (struct lbs *) create_label(); $1->for_goto = gen_label();}
    exp                             {$1->for_jmp_false = reserve_loc();}
      DO
        commands
      END                           {gen_code(GOTO, (struct stack_t) {.intval = $1->for_goto}); 
                                            back_patch($1->for_jmp_false, JMP_FALSE, (struct stack_t) {.intval = gen_label()});}
    
    /*
    {$$ = astCreateNo(WHILE_K, NULL, NULL, 0);astNo* children[] = { $2, $4 };astPutChild($$, children, 2);}
    */
;
exp:
    NUMBER {
        gen_code(LD_INT, (struct stack_t){.intval = $1, .type = INTVAL});
        
        /*
        char buffer[12];
        sprintf(buffer, "%d", $1);
        char* num_str = strdup(buffer);
        $$ = astCreateTerminal(NUM_K, num_str, NULL, 0, yylineno);
        */
    }
    | IDENTIFIER {
        context_check_used($1); /* Verifica se IDENTIFIER esta na tabela de simbolos e se teve atribuicao. */
        
        /*
        $$ = astCreateTerminal(VAR_K, $1, NULL, 0, yylineno);
        */
    }
    | exp '<' exp {
        gen_code(LT, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(LESS_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | exp '>' exp {
        gen_code(GT, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(GREATER_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | exp '+' exp {
        gen_code(ADD, (struct stack_t) {.intval = 0});
        
        /*
        $$ = astCreateNo(PLUS_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | exp '-' exp {
        gen_code(SUB, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(MINUS_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | exp '*' exp {
        gen_code(MULT, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(MULT_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | exp '/' exp {
        gen_code(DIV, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(DIV_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | exp '^' exp {
        gen_code(PWR, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(EXP_K, NULL, NULL, 0);
        astNo* children[] = { $1, $3 };
        astPutChild($$, children, 2);
        */
    }
    | '-' exp %prec UMINUS {
        gen_code(NEG, (struct stack_t) {.intval = 0});

        /*
        $$ = astCreateNo(UMINUS_K, NULL, NULL, 0);
        astPutChild($$, &($2), 1);
        */
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
