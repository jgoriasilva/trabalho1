

%{
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
void yyerror(char *c);
int yylex(void);
int count=0;

%}

%token NUMERO '+' '*' '/' '^' '(' ')' EOL

%%

S:
 	S exp1 EOL { printf("POP A\nResultado: %d\n", $2); }
 	|
	;

exp1:
	exp1 '+' exp2 {  $$ = $1 + $3; printf("POP A\nPOP B\nADD A, B\nPUSH A\n"); }
	| exp2 { $$ = $1; }
	;
	
exp2:
	exp2 '*' exp3 {  $$ = $1 * $3; printf("POP A\nPOP B\nMUL B\nPUSH A\n"); }
	| exp2 '/' exp3 {  $$ = $1 / $3; printf("POP B\nPOP A\nDIV B\nPUSH A\n"); }
	| exp3 { $$ = $1; /*printf("exp3: %d\n", $$);*/ }
	;
exp3:
 	exp3 '^' exp4 { $$ = pow($1,$3); printf("POP B\nPOP C\nMOV A, C\n.loop%d:\nMUL C\nDEC B\nCMP B, 1\nJNE .loop%d\nPUSH A\n", count, count); count++; }
	| exp4 { $$ = $1; /*printf("exp4: %d\n", $$);*/ }
	;

exp4:
	'(' exp1 ')' { $$ = $2; }
	| NUMERO { $$ = $1; printf ("PUSH %d\n", $1); }
	;



%%

void yyerror(char *s) {
	printf("ERRO: %s\n", s);
}

int main() {
  yyparse();
    return 0;

}
