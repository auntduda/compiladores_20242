#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>  // Para usar argumentos variaveis
#include <regex.h>
#include <ctype.h>

#include "otimizador.h" 
#include "../tabSimb.h"

const char *reservedWords[] = { "do", "end", "if", "else", "fi", "in",
		"integer", "let", "read", "skip", "then", "while", "write" };
const int numReservedWords = sizeof(reservedWords) / sizeof(reservedWords[0]);

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

	printf("Variaveis encontradas Expressão:\n");
	for (int i = 0; i < tamanho; i++) {
		printf("%s\n", variaveis[i]);
		/* Nesse momento temos que somar 10 na contagem da variável na tabela de símbolos */
		if (loopContador(tabela, variaveis[i]) == 0) {
			printf(
					"ERRO: Nao foi declarada uma variavel chamada na expressão: %s.\n",
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

	printf("Variaveis encontradas Comandos:\n");
	for (int i = 0; i < tamanho; i++) {
		printf("%s\n", variaveis[i]);
		/* Nesse momento temos que somar 10 na contagem da variável na tabela de símbolos */
		if (loopContador(tabela, variaveis[i]) == 0) {
			printf(
					"ERRO: Nao foi declarada uma variavel chamada nos comandos do loop: %s.\n",
					variaveis[i]);
		}
		free(variaveis[i]);
		achou = 1;
	}
	printf("=================================\n");
	if (achou) {
		return 1;
	}

	return 0;

}

char** capturar_parametros(const char *instrucao) {
    int estado = 0;
    char primeiro_numero[10] = {0};
    char segundo_numero[10] = {0};
    char numero_parenteses[10] = {0};
    int indice1 = 0, indice2 = 0, indice3 = 0;
    int i = 0;

    // Percorre a string caractere por caractere
    while (instrucao[i] != '\0') {
        char c = instrucao[i];

        switch (estado) {
            case 0:  // Captura o primeiro numero ate a virgula
                if (c == ',') {
                    estado = 1;  // Passa para o proximo numero
                } else {
                    primeiro_numero[indice1++] = c;
                }
                break;

            case 1:  // Captura o segundo numero ate o parentese
                if (c == '(') {
                    estado = 2;  // Passa para o numero dentro do parentese
                } else {
                    segundo_numero[indice2++] = c;
                }
                break;

            case 2:  // Captura o numero dentro do parentese
                if (c == ')') {
                    estado = 3;  // Finaliza a captura
                } else {
                    numero_parenteses[indice3++] = c;
                }
                break;
        }

        i++;  // Avanca para o proximo caractere
    }    
    // Alocando memoria para armazenar os ponteiros para as strings
    char **parametros = (char**)malloc(3 * sizeof(char*));

    // Alocando memoria para cada string individual e copiando os valores
    parametros[0] = (char*)malloc(strlen(primeiro_numero) + 1);
    strcpy(parametros[0], primeiro_numero);

    parametros[1] = (char*)malloc(strlen(segundo_numero) + 1);
    strcpy(parametros[1], segundo_numero);

    parametros[2] = (char*)malloc(strlen(numero_parenteses) + 1);
    strcpy(parametros[2], numero_parenteses);

    return parametros;
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
		/* Campos para minha máquina virtual de otimização */
		int reg[5];
		
		
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
	    // Exibe os resultados
	    printf("Linha: %s\n", numero_linha);
	    printf("Instrucao: %s\n", instrucao);
	    printf("Parametros: %s\n", parametros);
	    char**rds;
	    
	    if(strcmp(instrucao, "LD") == 0 || strcmp(instrucao, "ST") == 0){
	    	
	    	
	    	rds = capturar_parametros(parametros);
		    printf("=========================================\n");
		    printf("r: %s\n", rds[0]);
		    printf("d: %s\n", rds[1]);
		    printf("s: %s\n", rds[2]);
		    printf("=========================================\n");
		    char novaInstrucao[100];
		    
		    if(strcmp(instrucao, "ST") == 0){
		    	/* Caso Store */
		    	// Vou guardar o valor de um registrador no outro		
		    	/* Ao invés de escrever uma instrução de Store, vou escrever uma instrução de LDA, isso se os valores
		    	 * já não forem iguais
		    	 */
		    	if(atoi(rds[1]) == 0 && atoi(rds[2]) == 5){
		    		sprintf(novaInstrucao, " %2d:    LDA 2,0(%d)\n", atoi(numero_linha), atoi(rds[0]));
		    		
		    	}else if(atoi(rds[1]) == 1 && atoi(rds[2]) == 5){
		    		sprintf(novaInstrucao, " %2d:    LDA 3,0(%d)\n", atoi(numero_linha), atoi(rds[0]));
		    		
		    	}else if(atoi(rds[1]) == 2 && atoi(rds[2]) == 5){
		    		sprintf(novaInstrucao, " %2d:    LDA 4,0(%d)\n", atoi(numero_linha), atoi(rds[0]));
		    		
		    	}else{
		    		strcpy(novaInstrucao, linha);
		    	}
                /* Dessa forma sempre que fizermos um store estarei guardando no registrador respectivo */
		    	
		    }else{
		    	/* Caso Load 
		    	 * Então ao invés de escrever uma instrução de Load vou escrever uma instrução de LDA, isso se os valores
		    	 * já não forem iguais
		    	 * */
		    	// No load o valor de um registrador passa a ser do outro isso, se já não for o mesmo
		    	if(atoi(rds[1]) == 0 && atoi(rds[2]) == 5){
		    		sprintf(novaInstrucao, " %2d:    LDA %d,0(2)\n", atoi(numero_linha), atoi(rds[0]));
		    		
		    	}else if(atoi(rds[1]) == 1 && atoi(rds[2]) == 5){
		    		sprintf(novaInstrucao, " %2d:    LDA %d,0(3)\n", atoi(numero_linha), atoi(rds[0]));
		    		
		    	}else if(atoi(rds[1]) == 2 && atoi(rds[2]) == 5){
		    		sprintf(novaInstrucao, " %2d:    LDA %d,0(4)\n", atoi(numero_linha), atoi(rds[0]));
		    		
		    	}else{
		    		strcpy(novaInstrucao, linha);
		    	}
		    	/* Dessa forma estamos carregando sempre o valor 
		    	 * dos registradores de uso genérico
		    	 * E vamos aumentar a performance com um maior uso de registradores conforme necessário
		    	 */
		    	
		    }
		    
		    fprintf(arquivoOtimizado, novaInstrucao);
		    printf("--------------------------------------------------\n");
		    printf("Nova instrução: %s", novaInstrucao );
		    printf("--------------------------------------------------\n");
		    
	    }else{
	    	/* Preciso avaliar o conteúdo dos registradores com base nas instruções para saber se a instrução 
	    	 * LDA é necessária ou não
	    	 */
	    	fprintf(arquivoOtimizado, linha);
	    	printf("%s", linha );
	    }

	}
	
	fclose(arquivoOtimizado);

	fclose(arquivo);

	return 0;
}

