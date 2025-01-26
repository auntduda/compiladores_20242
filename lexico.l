%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sintatico.tab.h"
#include "ast/ast.h"
#include "tabSimb.h"
%}

%option yylineno
%option noinput nounput

/* auxiliares */
DIGIT             			[0-9]

/* identificadores */
COMMENT_BLOCK 				[/][*]([^*]|([*]+[^*/]))*[*]+[/]
COMMENT_LINE       			(\/\/).*
ID               			[a-z][a-z0-9_]*
NUM             	        {DIGIT}+
SPACE						[ \t\n]+

%%
":="						{ return(ASSGNOP);      }
do						    { return(DO);           }
end			    			{ return(END);          }
if 						    { return(IF);           }
else						{ return(ELSE);         }
fi 						    { return(FI);           }
in		    				{ return(IN);           }
integer					    { return(INTEGER);      }
let			    			{ return(LET);          }
read			    		{ return(READ);         }
skip						{ return(SKIP);         }
then						{ return(THEN);         }
while						{ return(WHILE);        }
write						{ return(WRITE);        }

{COMMENT_LINE}				/* Nada */
{COMMENT_BLOCK}				/* Nada */
{ID}                        { yylval.id = (char *) strdup(yytext);
                              return(IDENTIFIER);   }
{NUM}			            { yylval.intval = atoi(yytext);
                              return(NUMBER);       }
{SPACE}					    /* Nada */
.						    { return(yytext[0]);    } /* Qualquer token de 1 caractere (-, +, *, ;) cai pra esse caso, onde o token retornado é o próprio caractere */
%%

int yywrap() {
  return 1;
}
