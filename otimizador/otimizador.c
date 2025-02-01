#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>  // Para usar argumentos variaveis
#include <regex.h>
#include <ctype.h>

#include "otimizador.h" 
#include "../tabSimb.h"

const char* reservedWords[] = {
    "do", "end", "if", "else", "fi", "in", "integer", "let", "read", "skip", "then", "while", "write"
};
const int numReservedWords = sizeof(reservedWords) / sizeof(reservedWords[0]);


int isVariable(const char* word) {
    if (!isalpha(word[0])) return 0;
    for (int i = 1; word[i] != '\0'; i++) {
        if (!isalnum(word[i]) && word[i] != '_') return 0;
    }
    return 1;
}

int isReservedWord(const char* word) {
    for (int i = 0; i < numReservedWords; i++) {
        if (strcmp(word, reservedWords[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

void extractVariables(const char* codigo, char* variaveis[], int* tamanho) {
    char buffer[100];

    while (*codigo) {
        if (isalpha(*codigo)) {
            int i = 0;
            while (isalnum(*codigo) || *codigo == '_') {
                buffer[i++] = *codigo++;
            }
            buffer[i] = '\0';
            if (isVariable(buffer) && !isReservedWord(buffer)) {
                variaveis[*tamanho] = strdup(buffer);
                (*tamanho)++;
            }
        } else {
            codigo++; /* Vai para o proximo endereco */
        }
    }
}



char* concatStr(int num, ...) {
    va_list args;
    va_start(args, num);

    // Alocar espaco inicial para a string resultante
    char* resultado = (char*)malloc(200 * sizeof(char));
    resultado[0] = '\0';  // Inicializa a string vazia

    for (int i = 0; i < num; i++) {
        char* str = va_arg(args, char*);
        strcat(resultado, str);  // Concatena ao resultado
    }

    va_end(args);
    return resultado;
}

int expressionProcessing(char* exp, tabSimb tabela){
    // elemTab* elemAtual = tabela.primeiro;
    
    char* variaveis[10];
    int tamanho = 0;
    int achou = 0;
    
    extractVariables(exp, variaveis, &tamanho);
    
    
    printf("Variaveis encontradas Expressão:\n");
    for (int i = 0; i < tamanho; i++) {
        printf("%s\n", variaveis[i]);
        /* Nesse momento temos que somar 10 na contagem da variável na tabela de símbolos */
        free(variaveis[i]);
        achou = 1;
    }
    if (achou) {
		return 1;
	}
    
    return 0;
	
	
}
int commandsProcessing(char* commands, tabSimb tabela){
    // elemTab* elemAtual = tabela.primeiro;
    
    char* variaveis[10];
    int tamanho = 0;
    int achou = 0;
    
    extractVariables(commands, variaveis, &tamanho);
    
    
    printf("Variaveis encontradas Comandos:\n");
    for (int i = 0; i < tamanho; i++) {
        printf("%s\n", variaveis[i]);
        /* Nesse momento temos que somar 10 na contagem da variável na tabela de símbolos */
        free(variaveis[i]);
        achou = 1;
    }
    printf("=================================\n");
    if (achou) {
		return 1;
	}
    
    return 0;
	
	
}















