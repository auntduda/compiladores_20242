%{
#include <stdio.h>
#include <string.h>
%}



/* auxiliares */
DIGIT             			[0-9]
SIGN						[+-]

/* identificadores */
COMMENT_BLOCK 				[/][*]([^*]|([*]+[^*/]))*[*]+[/]
COMMENT_LINE       			(\/\/).*
ID               			[a-z][a-z0-9_-]*
NUMBER_FLOAT               	{SIGN}?{DIGIT}+[.]{DIGIT}*
NUMBER_INTEGER             	{SIGN}?{DIGIT}+
SPACE						[ \t\n]+

%%
":="						{printf("atribuicao: %s \n",yytext) ;}
do							{printf("especial:  %s \n",yytext) ;}
else						{printf("especial: %s \n",yytext) ;}
end			    			{printf("especial: %s\n",yytext) ;}
float						{printf("especial: %s \n",yytext) ;}
if 							{printf("especial: %s \n",yytext) ;}
in		    				{printf("especial: %s\n",yytext) ;}
integer						{printf("especial: %s\n",yytext) ;}
let			    			{printf("especial: %s\n",yytext) ;}
read			    		{printf("especial: %s\n",yytext) ;}
read_ft						{printf("especial: %s\n",yytext) ;}
skip						{printf("especial: %s\n",yytext) ;}
then						{printf("especial: %s\n",yytext) ;}
while						{printf("especial: %s\n",yytext) ;}
write						{printf("especial: %s\n",yytext) ;}
write_ft					{printf("especial: %s\n",yytext) ;}

{COMMENT_LINE}				{printf("comment line \n");}
{COMMENT_BLOCK}				{printf("comment block\n");}
{ID}                        {printf("retornando um identificador:  %s\n",yytext) ;}
{NUMBER_FLOAT}				{printf("é float %s\n",yytext) ;} /* @TODO: float */
{NUMBER_INTEGER}			{printf("é inteiro %s\n",yytext) ;}
{SPACE}						{printf("----espaço---- \n");}
.							{printf("nao faz parte da simple");}
%%

int yywrap(){}
int main(){


yylex();
printf("\nNumber of Capital letters " 
      "in the given input - \n");

return 0;
}