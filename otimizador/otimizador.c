#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>  // Para usar argumentos variaveis
#include <regex.h>
#include <ctype.h>

#include "otimizador.h" 
#include "../tabSimb.h"

#define NUM_REG 8
#define DADDR_SIZE 1024
#define PC_REG 7  // Registrador de contador de programa (PC)

int reg[NUM_REG] = { 0 };    // Registradores r0 a r7 (PC)
int dMem[DADDR_SIZE] = { 0 }; // Memoria de dados

const char *reservedWords[] = { "do", "end", "if", "else", "fi", "in",
		"integer", "let", "read", "skip", "then", "while", "write" };
const int numReservedWords = sizeof(reservedWords) / sizeof(reservedWords[0]);

void extrairParametros(char *parametros, int *r, int *s, int *t, int *d) {
    if (strchr(parametros, '(') != NULL) {
        sscanf(parametros, "%d,%d(%d)", r, d, s);
        *t = 0;
    } else {
        sscanf(parametros, "%d,%d,%d", r, s, t);
        *d = 0;
    }
}
int isVariable(const char *word) {
	if (!isalpha(word[0]))
		return 0;
	for (int i = 1; word[i] != '\0'; i++) {
		if (!isalnum(word[i]) && word[i] != '_')
			return 0;
	}
	return 1;
}

int isReservedWord(const char *word) {
	for (int i = 0; i < numReservedWords; i++) {
		if (strcmp(word, reservedWords[i]) == 0) {
			return 1;
		}
	}
	return 0;
}

void extractVariables(const char *codigo, char *variaveis[], int *tamanho) {
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
	char *resultado = (char*) malloc(200 * sizeof(char));
	resultado[0] = '\0';  // Inicializa a string vazia

	for (int i = 0; i < num; i++) {
		char* str = va_arg(args, char*);
		strcat(resultado, str);  // Concatena ao resultado
	}

	va_end(args);
	return resultado;
}

int expressionProcessing(char *exp, tabSimb tabela) {
	// elemTab* elemAtual = tabela.primeiro;

	char *variaveis[10];
	int tamanho = 0;
	int achou = 0;

	extractVariables(exp, variaveis, &tamanho);

	
	for (int i = 0; i < tamanho; i++) {
		/* Nesse momento temos que somar 10 na contagem da vari��vel na tabela de s��mbolos */
		if (loopContador(tabela, variaveis[i]) == 0) {
			printf(
					"ERRO: Nao foi declarada uma variavel chamada na expressao: %s.\n",
					variaveis[i]);
		}
		free(variaveis[i]);
		achou = 1;
	}
	if (achou) {
		return 1;
	}

	return 0;

}
int commandsProcessing(char *commands, tabSimb tabela) {
	// elemTab* elemAtual = tabela.primeiro;

	char *variaveis[10];
	int tamanho = 0;
	int achou = 0;

	extractVariables(commands, variaveis, &tamanho);

	for (int i = 0; i < tamanho; i++) {
		/* Nesse momento temos que somar 10 na contagem da vari��vel na tabela de s��mbolos */
		if (loopContador(tabela, variaveis[i]) == 0) {
			printf(
					"ERRO: Nao foi declarada uma variavel chamada nos comandos do loop: %s.\n",
					variaveis[i]);
		}
		free(variaveis[i]);
		achou = 1;
	}
	if (achou) {
		return 1;
	}

	return 0;

}

int optimizeCode(char *arquivoTiny, tabSimb tabela) {
	FILE *arquivo = fopen(arquivoTiny, "r");
	/* Abrindo arquivo otimizado para escrita */
	// Remove o arquivo antigo se existir
	FILE *arquivoOtimizado = fopen("otimizador/FATORIALo.tm", "w");

	if (arquivoOtimizado == NULL) {
		printf("Erro ao abrir o arquivo!\n");
		return 1;
	}

	if (arquivo == NULL) {
		printf("Erro ao abrir o arquivo: %s\n", arquivoTiny);
		return 1;
	}

	char linha[1024];

	while (fgets(linha, sizeof(linha), arquivo) != NULL) {
		int reg[2] = {0,1}; /* Mapeamento de registradores a serem substituidos*/
		int necessaria = 1;
		int r, s, t, d = 0;
		int i = 0;
		char numero_linha[10];
		char instrucao[10];
		char parametros[50];
		memset(numero_linha, 0, sizeof(numero_linha));
		memset(instrucao, 0, sizeof(instrucao));
		memset(parametros, 0, sizeof(parametros));
		
		

		int estado = 0;  // Automato simples baseado em estados

		int indice_numero = 0, indice_instrucao = 0, indice_parametros = 0;
		while (linha[i] != '\0') {
			char c = linha[i];

			switch (estado) {
			case 0:
				// if (isspace(c)) break; 
				// Captura o numero da linha
				if (isdigit(c)) {
					numero_linha[indice_numero++] = c;
				} else if (c == ':') {
					estado = 1;  // Passa a capturar a instrucao
				}
				break;

			case 1:
				// Ignora espacos apos o numero
				if (!isspace(c)) {
					instrucao[indice_instrucao++] = c;
					estado = 2;  // Passa a capturar a instrucao de fato
				}
				break;
			case 2:  // Continua capturando a instrucao
				if (isspace(c)) {
					estado = 3;  // Passa para a captura dos parametros
				} else {
					instrucao[indice_instrucao++] = c;
				}
				break;

			case 3:  // Captura os parametros
				if (c != '\n' && c != '\0') {
					parametros[indice_parametros++] = c;
				}
				break;
			}
			i++;
		}
		
		extrairParametros(parametros, &r, &s, &t, &d);
		

		if (strcmp(instrucao, "LD") == 0 || strcmp(instrucao, "ST") == 0) {
			char novaInstrucao[100];

			if (strcmp(instrucao, "ST") == 0) {
                /* Ao inves de escrever store vamos escrever lda*/
				if (d == 0 && s == 5) {
					sprintf(novaInstrucao, " %2d:    LDA 2,0(%d)\n",
							atoi(numero_linha), r);

				} else if (d == 1 && s == 5) {
					sprintf(novaInstrucao, " %2d:    LDA 3,0(%d)\n",
							atoi(numero_linha), r);

				} else if (d == 2 && s == 5) {
					sprintf(novaInstrucao, " %2d:    LDA 4,0(%d)\n",
							atoi(numero_linha), r);
				} else {
					strcpy(novaInstrucao, linha);
				}
				/* Dessa forma sempre que fizermos um store estarei guardando no registrador respectivo */

			} else {
				/* Ao inves de escrever Load vou escrever LDA*/
				if (d == 0 && s == 5) {
					sprintf(novaInstrucao, " %2d:    LDA %d,0(2)\n",
							atoi(numero_linha), r);
				    

				} else if (d == 1 && s == 5) {
					sprintf(novaInstrucao, " %2d:    LDA %d,0(3)\n",
							atoi(numero_linha), r);

				} else if (d == 2 && s == 5) {
					sprintf(novaInstrucao, " %2d:    LDA %d,0(4)\n",
							atoi(numero_linha), r);

				} else {
					strcpy(novaInstrucao, linha);
				}
				/* Todas as vezes que for utilizado o registrador 0 a partir de agora vamos trocar por registrador 
				   que foi carregado pra ele
				 */

			}

			fprintf(arquivoOtimizado, novaInstrucao);
		} else {
			/* Caso não seja load e store não vou trocar por LDA*/

			fprintf(arquivoOtimizado, linha);
		}
	}

	fclose(arquivoOtimizado);

	fclose(arquivo);

	return 0;
}

