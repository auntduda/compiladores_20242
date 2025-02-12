#ifndef TABSIMB_H
#define TABSIMB_H

#include "ast/gc.h"

/* Struct que corresponde a um elemento da tabela de simbolos. */
typedef struct elemTab {
    char* nome; // Nome do simbolo
    int offset; // posicao do elemento na tabela
    struct elemTab* prox; // Endereco do elemento seguinte da lista
} elemTab;

static elemTab* symTab = (elemTab *) 0;

static inline elemTab* inSimb(char* sym)
{
    elemTab* ptr = (elemTab *) malloc (sizeof(elemTab));
    ptr->nome = (char *) malloc(strlen(sym) + 1);
    strcpy(ptr->nome, sym);
    ptr->offset = data_location();
    ptr->prox = (struct elemTab *) symTab;
    symTab = ptr;
    return ptr;
}

static inline elemTab* getSimb(char* sym)
{
    for (elemTab* ptr = symTab; ptr != (elemTab *) 0; ptr = (elemTab *) ptr->prox)
        if (strcmp(ptr->nome, sym) == 0) return ptr;
    return 0;
}

static inline void clearTable (elemTab* ptr)
{
    if (ptr == NULL) return;

    clearTable(ptr->prox);
    free(ptr->nome);
    free(ptr);
}

#endif