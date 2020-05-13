

%{
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
void yyerror(char *c);
int yylex(void);

%}

%token NUMERO '+' '-' '*' '/' '^' '(' ')' EOL

%%

S:
 	 S exp1 EOL { printf("Resultado: %d\n", $2); }
 	|
	;

exp1:
	exp1 '+' exp2 {  $$ = $1 + $3; printf("soma: %d\n", $$); }
	| exp1 '-' exp2 { $$ = $1 - $3; printf("sub: %d\n", $$); }
	| exp2 { $$ = $1; printf("exp2: %d\n", $$); }
	;
	
exp2:
	exp2 '*' exp2 { $$ = $1 * $3; printf("mul: %d\n", $$); } 
	| exp2 '/' exp2 { $$ = $1 / $3; printf("div: %d\n", $$); }
	| exp3 { $$ = $1; printf("exp3: %d\n", $$); }
	;
exp3:
 	exp3 '^' exp4 { $$ = pow($1,$3); printf("pow: %d\n", $$); }
	| exp4 { $$ = $1; printf("exp4: %d\n", $$); }
	;

exp4:
	'(' exp1 ')' { $$ = $2; printf("par: %d\n", $$); }
	| NUMERO { $$ = $1; printf ("num: %d\n", $1); }
	;



%%

void yyerror(char *s) {
	printf("ERRO: %s\n", s);
}

int main() {
  yyparse();
    return 0;

}
