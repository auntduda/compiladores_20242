# Variaveis
CC = gcc
LEX = flex
BISON = bison
CFLAGS = -Wall -g
TARGET = a.out
MKDIR_P ?= mkdir -p
BUILD_DIR ?= build
OUT_DIR ?= out

# Arquivos de entrada
LEX_FILE = lexico.l
BISON_FILE = sintatico.y
AST_DIR = ast
AST_SRC = $(AST_DIR)/ast.c
AST_HDR = $(AST_DIR)/ast.h
SYM_SRC = tabSimb.c
SYM_HDR = tabSimb.h

# Arquivos gerados
BISON_C = sintatico.tab.c
BISON_H = sintatico.tab.h
LEX_C = lex.yy.c
OBJ = $(BISON_C) $(LEX_C)

# Arquivos de teste
TEST_FILES = teste.simple

# Regra padrao
all: $(TARGET)

# Regra para gerar o arquivo de saida
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)
	$(MKDIR_P) $(BUILD_DIR) $(OUT_DIR)

# Regra para o Bison
$(BISON_C) $(BISON_H): $(BISON_FILE)
	$(BISON) -d $(BISON_FILE)

# Regra para o Flex
$(LEX_C): $(LEX_FILE)
	$(LEX) $(LEX_FILE)

# Limpeza de arquivos gerados
clean:
	rm -f $(BISON_C) $(BISON_H) $(LEX_C) $(TARGET)

# Teste do programa
run: $(TARGET)
	./$(TARGET) $(TEST_FILES)

# Ajuda
help:
	@echo "Comandos disponiveis:"
	@echo "  make         - Compila todo o projeto"
	@echo "  make run     - Executa o programa com arquivos de teste"
	@echo "  make clean   - Remove arquivos gerados"
	@echo "  make help    - Exibe esta mensagem de ajuda"
