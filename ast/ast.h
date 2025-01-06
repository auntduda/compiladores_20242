#ifndef AST_H
#define AST_H

typedef enum token Token;

enum token{
	PROGRAM_K = 0,
	DECLARATIONS_K,
	COMMANDS_K,
	VAR_K,
	SKIP_K,
	READ_K,
	WRITE_K,
	ASSIGN_K,
	IF_K,
	WHILE_K,
	NUM_K,
	MULT_K,
	DIV_K,
	LESS_K,
	GREATER_K,
	PLUS_K,
	EXP_K,
	MINUS_K,
	UMINUS_K,
	BLANK
};


typedef struct astNo{
	Token label;
	char* instance;
	struct astNo* sibling;
	struct astNo** child;

	unsigned short line;
	// Children len
	int len_child;
} astNo;

/*
 * Begin struct with empty*/
astNo* astInit();

/*
 * Creates allocated children of size sz
 * 1: successfull
 * -1: error
 * */

//int astCreateChild(astNo* no, int sz);

/*
 * References multiple children to child
 * WARN - If for any i'th child target[i] is NULL
 * then target[i] is not assigned and sz is automatically decreased
 * sz: Quantity of children
 * 1: successfull
 * 0: nothing happened
 * -1: error
 * */
int astPutChild(astNo* no, astNo** target, int sz);

/*
 * Allocates no to sibling
 * 1: successfull
 * 0: Nothing happened
 * -1: error
 * */
int astInsertSibling(astNo* no, astNo target);

/*
 * Reference multiple *Target to siblings
 * If some target[i] is null, target[i] is not assigned
 * len: quantity of sibling to put
 * 1: successfull
 * -1: error
 * */
int astPutSibling(astNo* no, astNo** target, int len);

/*
 * Assign data to no without allocate it. The data inside is allocated (except child)
 * (astNo): copy of no created
 * */
astNo astNewNo(Token label, char* instance, astNo** child, int len_child);

/*
 * Assign data allocating it. The data inside is also allocated (except child)
 * (astNo*): addr of no created and allocated
 * */
astNo* astCreateNo(Token label, char* instance, astNo** child, int len_child);

/*
 * Assign data allocating it. The data inside is also allocated (except child). Also stores line of occurence
 * (astNo*): addr of no created and allocated
 * */
astNo* astCreateTerminal(Token label, char* instance, astNo** child, int len_child, int line_log);

/*
 * Free entire tree*/
int astFree(astNo* tree);

/*
 * Free deep inside tree*/
int astDeepFree(astNo* no);

/*
 * Print the tree with important info*/
void astPrintInfo(astNo* no);

/*
 * Print the tree*/
void astPrint(astNo* no);

/*
 * Print the tree in a pretty way*/
void print_ast_with_lines(astNo* root, int depth, int is_last);

/*
 * Print the tree in a pretty way (auxiliar function)*/
void print_indent(int depth, int is_last);

/*
 * Save at file given by path*/
int astSave(astNo* tree, char* path);

void astUpdateLine(astNo* no, int line);

// TEMP
char* tokenStr(Token tok);

#endif

