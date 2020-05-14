

%{
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
void yyerror(char *c);
int yylex(void);
int count=0;
int mem[26];

%}

%union
{
	int valor;
	char rotulo;
};


%token NUM VAR '+' '*' '/' '^' '(' ')' '=' EOL
%type <valor> NUM
%type <rotulo> VAR

%%

S:
 	S exp1 EOL { printf("POP A\nResultado: %d\n", $<valor>2); }
	| S C EOL {}
 	|
	;

C:
 	VAR '=' exp1 { mem[$<rotulo>1-'a'] = $<valor>3; printf("POP A\n"); }
	;

exp1:
	exp1 '+' exp2 {  $<valor>$ = $<valor>1 + $<valor>3; printf("POP A\nPOP B\nADD A, B\nPUSH A\n"); }
	| exp2 { $<valor>$ = $<valor>1; }
	;
	
exp2:
	exp2 '*' exp3 {  $<valor>$ = $<valor>1 * $<valor>3; printf("POP A\nPOP B\nMUL B\nPUSH A\n"); }
	| exp2 '/' exp3 {  $<valor>$ = $<valor>1 / $<valor>3; printf("POP B\nPOP A\nDIV B\nPUSH A\n"); }
	| exp3 { $<valor>$ = $<valor>1; /*printf("exp3: %d\n", $$);*/ }
	;
exp3:
 	exp3 '^' exp4 { $<valor>$ = pow($<valor>1,$<valor>3); printf("POP B\nPOP C\nMOV A, C\n.loop%d:\nMUL C\nDEC B\nCMP B, 1\nJNE .loop%d\nPUSH A\n", count, count); count++; }
	| exp4 { $<valor>$ = $<valor>1; /*printf("exp4: %d\n", $$);*/ }
	;

exp4:
	'(' exp1 ')' { $<valor>$ = $<valor>2; }
	| NUM { $<valor>$ = $<valor>1; printf ("PUSH %d\n", $<valor>1); }
	| VAR { $<valor>$ = mem[$<rotulo>1-'a']; printf("PUSH %d\n", $<valor>$); }
	;



%%

void yyerror(char *s) {
	printf("ERRO: %s\n", s);
}

int main() {
  yyparse();
    return 0;

}
