# Compiladores - 2024.2

Repositório de armazenamento do compilador que será elaborado para a disciplina de CIC0204 - Compiladores

## Requisitos
- flex 2.6.4
- bison 3.7.4

## Como testar o analisador léxico/sintático?

Para testar o `sintatico.y`, rode:

``flex lexico.l && bison -d sintatico.y && gcc sintatico.tab.c lex.yy.c && ./a.out teste.simple``