
%{
#include <stdlib.h>
void yyerror(char *);

#include "y.tab.h"
#include "math.h"

%}

/*
%token NUM VAR '+' '*' '/' '^' '(' ')' '=' EOL
*/


%%

	/* Lista de regras para geração dos tokens visando implementar uma calculadora. 
	*  As operações da calculadora são +, *, /, ^ e os parênteses ( e ).
	*  A identificação dos tokens é auto-explicativa.	
	*  Há também os tokens '=' e EOL, que representam os caracteres = e \n, respectivamente.
	*  O primeiro serve para que a calculadora execute atribuição de valores a variaveis.
	*  O segundo, para indicar o fim de uma expressão/comando a ser executado pela calculadora. 
	*/

\+ 	{ return '+'; }
\* 	{ return '*'; }
\/ 	{ return '/'; }
\^ 	{ return '^'; }
\( 	{ return '('; }
\) 	{ return ')'; }
\= 	{ return '='; }
\n 	{ return EOL; }

	/* Os números suportados pela calculadora são inteiros. Os tokens relacionados a estes são chamados de NUM */
[0-9]+ 	{ yylval.valor = atoi(yytext); return NUM; }

	/* As variáveis implementadas são caracteres simples do alfabeto inglês i.e. letras de a até z. Os tokens são chamados de VAR. */
[a-z]	{ yylval.rotulo = yytext[0];   return VAR; }

	/* A calculadora ignora caracteres diferentes dos supracitados. */
. 

%%

int yywrap() {
  return 1;
}
