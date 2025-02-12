#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabSimb.h"
#include "ast/gc.h"

elemTab* inSimb(char* sym)
{
    elemTab* ptr = (elemTab *) malloc (sizeof(elemTab));
    ptr->nome = (char *) malloc(strlen(sym) + 1);
    strcpy(ptr->nome, sym);
    ptr->offset = data_location();
    ptr->prox = (struct elemTab *) symTab;
    symTab = ptr;

    printf("inSimb\n"); printf("%ud\n", symTab);
    return ptr;
}

elemTab* getSimb(char* sym)
{
    for (elemTab* ptr = symTab; ptr != (elemTab *) 0; ptr = (elemTab *) ptr->prox)
        if (strcmp(ptr->nome, sym) == 0) return ptr;
    return 0;
}

void clearTable (elemTab* ptr)
{
    if (ptr == NULL) return;

    clearTable(ptr->prox);
    free(ptr->nome);
    free(ptr);
}