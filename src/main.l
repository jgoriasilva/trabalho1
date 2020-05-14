
%{
#include <stdlib.h>
void yyerror(char *);

#include "y.tab.h"
#include "math.h"

%}

/*
%token NUMERO '+' '*' '/' '^' '(' ')' EOL
*/


%%

\+ 	{ return '+'; }
\* 	{ return '*'; }
\/ 	{ return '/'; }
\^ 	{ return '^'; }
\( 	{ return '('; }
\) 	{ return ')'; }
\= 	{ return '='; }
\n 	{ return EOL; }
[0-9]+ 	{ yylval.valor = atoi(yytext); return NUM; }
[a-z]	{ yylval.rotulo = yytext[0];   return VAR; }
. 

%%

int yywrap() {
  return 1;
}
