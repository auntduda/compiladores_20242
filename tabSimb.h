#ifndef TABSIMB_H
#define TABSIMB_H

/* Struct que corresponde a um elemento da tabela de simbolos. */
typedef struct elemTab {
    char* nome; // Nome do simbolo
    char tipo; /* Tipo da variavel. Embora a nossa linguagem tenha apenas um tipo, colocar este campo facilita uma possivel modificacao da linguagem que inclua novos tipos. */
    char usado; /* Afirma se a variavel foi usada ou nao. */
    void* conteudo; /* Endereco do conteudo da variavel. */
    struct elemTab* prox; // Endereco do elemento seguinte da lista
} elemTab;

/* Struct que corresponde a tabela de simbolos. */
typedef struct tabSimb {
    elemTab* primeiro; /* endereco do primeiro elemento da tabela. */
    unsigned int tamanho; /* Quantidade de elementos da tabela. */
} tabSimb;

tabSimb criaTabela();
char pushElem(tabSimb* tabela, char* nome, char tipo);
char inTab(tabSimb tabela, char* nome);
char getElem(tabSimb tabela, char* nome, elemTab** endereco);
char naoUsado(tabSimb tabela);
void printTab(tabSimb tabela);

#endif