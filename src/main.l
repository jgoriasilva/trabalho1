
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

\+ { return '+'; }
\* { return '*'; }
\/ { return '/'; }
\^ { return '^'; }
\( { return '('; }
\) { return ')'; }
\n { return EOL; }
[0-9]+ { yylval = atoi(yytext); return NUMERO; }
. 

%%

int yywrap() {
  return 1;
}
