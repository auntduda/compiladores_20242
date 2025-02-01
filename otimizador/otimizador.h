#ifndef OPT_H
#define OPT_H

#include <stdarg.h>  // Para usar argumentos variaveis


void inserirString(char ***lista, int *tamanho, const char *novaString);

void limparLista(char ***lista, int *tamanho);

int stringJaExiste(char **lista, int tamanho, const char *novaString);

char* concat_str(int num, ...);


#endif

