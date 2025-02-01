#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>  // Para usar argumentos variaveis

#include "otimizador.h" 

// Funcao para verificar se a string ja existe na lista
int stringJaExiste(char **lista, int tamanho, const char *novaString) {
	for (int i = 0; i < tamanho; i++) {
		if (strcmp(lista[i], novaString) == 0) {
			return 1;  // A string ja existe
		}
	}
	return 0;  // A string nao foi encontrada
}

// Funcao para inserir uma string na lista de strings
void inserirString(char ***lista, int *tamanho, const char *novaString) {
    // Se a string já está na lista não precisa inserí-la novamente
	if (stringJaExiste(*lista, *tamanho, novaString)) {
		return;
	}

	// Realoca memoria para o array de strings, incrementando o tamanho
	*lista = realloc(*lista, (*tamanho + 1) * sizeof(char*));
	if (*lista == NULL) {
		printf("Erro ao alocar memoria!\n");
		exit(1);
	}

	// Aloca memoria para a nova string e copia seu conteudo
	(*lista)[*tamanho] = malloc(strlen(novaString) + 1);
	if ((*lista)[*tamanho] == NULL) {
		printf("Erro ao alocar memoria para a string!\n");
		exit(1);
	}
	strcpy((*lista)[*tamanho], novaString);

	// Atualiza o tamanho do array
	(*tamanho)++;
}


// Funcao para limpar todos os elementos da lista
void limparLista(char ***lista, int *tamanho) {
    for (int i = 0; i < *tamanho; i++) {
        free((*lista)[i]);  // Libera cada string
    }
    free(*lista);  // Libera o array de ponteiros
    *lista = NULL;  // Evita ponteiros danificados
    *tamanho = 0;   // Define o tamanho como 0
}



char* concat_str(int num, ...) {
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















