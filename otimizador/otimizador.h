#ifndef OPT_H
#define OPT_H

#include <stdarg.h>  // Para usar argumentos variaveis
#include "../tabSimb.h"


int isVariable(const char* word);

int isReservedWord(const char* word);

void extractVariables(const char* codigo, char* variaveis[], int* tamanho);

char* concatStr(int num, ...);

int expressionProcessing(char* number, tabSimb tabela);

int commandsProcessing(char* number, tabSimb tabela);

char** capturar_parametros(const char *instrucao);

int optimizeCode(char* arquivoTiny, tabSimb tabela);

#endif

