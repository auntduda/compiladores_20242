#ifndef TABSIMB_H
#define TABSIMB_H

/* Struct que corresponde a um elemento da tabela de simbolos. */
typedef struct elemTab {
    char* nome; // Nome do simbolo
    int offset; // posicao do elemento na tabela
    struct elemTab* prox; // Endereco do elemento seguinte da lista
} elemTab;

static elemTab* symTab = (elemTab *) 0;

elemTab* inSimb(char* sym);
elemTab* getSimb(char* sym);
void clearTable (elemTab* ptr);

#endif