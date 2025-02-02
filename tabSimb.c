#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabSimb.h"

/* Funcao que cria uma nova tabela de simbolos. */
tabSimb criaTabela(){
    tabSimb novaTabela;
    novaTabela.primeiro = (elemTab*) malloc(sizeof(elemTab)); /* Aloca memoria para o primeiro elemento. */
    novaTabela.tamanho = 0;
    novaTabela.primeiro -> prox = (elemTab*) malloc(sizeof(elemTab)); /* Aloca memoria para o segundo elemento. */

    return novaTabela;
}

/* Funcao que coloca um novo elemento na tabela. Se o novo elemento tiver o mesmo nome de algum elemento ja presente na tabela, ele nao sera acrescentado e a funcao retornara 1. */
char pushElem(tabSimb* tabela, char* nome, char tipo){
    elemTab* novoElem = tabela -> primeiro; /* Guarda o endereco do proximo elemento da tabela. */

    /* Laco que procura o endereco do proximo elemento a ser colocado na tabela. */
    for (unsigned int i = 0; i < tabela -> tamanho; i++){
        /* Verifica se o elemento a ser colocado tem nome igual. Se tiver, retorna 1. */
        if (strcmp(novoElem -> nome, nome) == 0) return 1;
        novoElem = novoElem -> prox;
    }

    /* Preenche os campos do proximo elemento da tabela. */
    novoElem -> tipo = tipo;
    novoElem -> nome = nome;
    novoElem -> usado = 0;
    novoElem -> contador = 0;
    novoElem -> reg = 0;
    novoElem -> prox = (elemTab*) malloc(sizeof(elemTab));
    tabela -> tamanho += 1;

    return 0;
}

/* Funcao que verifica se ja existe um elemento da tabela com o nome. Retorna 1 se houver e zero se nao. */
char inTab(tabSimb tabela, char* nome){
    elemTab* elemAtual = tabela.primeiro;

    for (unsigned int i = 0; i < tabela.tamanho; i++){
        if (strcmp(elemAtual -> nome, nome) == 0) return 1;
        elemAtual = elemAtual -> prox;
    }

    return 0;
}

/* Funcao que procura um elemento na tabela e guarda seu endereco na variavel endereco. Se o elemento nao for encontrado, retorna 0 */
char getElem(tabSimb tabela, char* nome, elemTab** endereco){
    elemTab* elemAtual = tabela.primeiro;

    for (unsigned int i = 0; i < tabela.tamanho; i++){
        if (strcmp(elemAtual -> nome, nome) == 0){
            *endereco = elemAtual;
            elemAtual->contador++;
            return 1;
        }
        elemAtual = elemAtual -> prox;
    }

    return 0;
}

/* Soma em 10 o contador de ocorrencias das variaveis dentro de loops */
char loopContador(tabSimb tabela, char* nome){
    elemTab* elemAtual = tabela.primeiro;
    for (unsigned int i = 0; i < tabela.tamanho; i++){
        if (strcmp(elemAtual -> nome, nome) == 0){
        	elemAtual->contador = (elemAtual->contador + 10);
            return 1;
        }
        elemAtual = elemAtual -> prox;
    }

    return 0;
}




/* Funcao que verifica se existe alguma variavel que nao foi usada na tabela. As variaveis que nao foram usados sao impressos na tela. */
char naoUsado(tabSimb tabela){
    elemTab* elemAtual = tabela.primeiro;
    char existeNaoUsado = 0;

    for (unsigned int i = 0; i < tabela.tamanho; i++){
        if (elemAtual->usado == 0){
            printf("A variavel %s nao foi usada.\n", elemAtual -> nome);
            existeNaoUsado = 1;
        }
        elemAtual = elemAtual -> prox;
    }

    return existeNaoUsado;
}

/* Funcao que imprime o conteudo da tabela na tela. */
void printTab(tabSimb tabela){
    elemTab* elemento = tabela.primeiro;

    if (tabela.tamanho == 0){
        printf("Nenhuma variavel foi declarada.\n");
        return;
    }

    printf("Variaveis declaradas:\n");
    for (unsigned int i = 0; i < tabela.tamanho; i++){
        printf("%s -- %d\n", elemento -> nome, elemento->contador);
        elemento = elemento -> prox;
    }

    return;
}
