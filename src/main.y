

%{
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
void yyerror(char *c);
int yylex(void);
int count=0;
int mem[26];
int flag[26] = {0};

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
 	S exp1 EOL { 	printf("\tPOP A\n; Resultado: %d\n; ", $<valor>2); }
	| S C EOL { printf("\tPOP A\n; "); }
 	|
	;

C:
 	VAR '=' exp1 {	char name = $<rotulo>1;
			mem[name-'a'] = $<valor>3; 
			if(!flag[name-'a']) {
				printf("\tJMP jump%c\nv%c:\njump%c:\n\tMOV C, v%c\n\tMOV [C], %d\n", name, name, name, name, $<valor>3); 
				flag[name-'a'] = 1; }
			else
				printf("\tMOV C, v%c\n\tMOV [C], %d\n", name, $<valor>3); }
	;

exp1:
	exp1 '+' exp2 {	$<valor>$ = $<valor>1 + $<valor>3; 
			printf("\tPOP A\n\tPOP B\n\tADD A, B\n\tPUSH A\n"); }
	| exp2 { $<valor>$ = $<valor>1; }
	;
	
exp2:
	exp2 '*' exp3 {	$<valor>$ = $<valor>1 * $<valor>3; 
			printf("\tPOP A\n\tPOP B\n\tMUL B\n\tPUSH A\n"); }
	| exp2 '/' exp3 {	$<valor>$ = $<valor>1 / $<valor>3; 
				printf("\tPOP B\n\tPOP A\n\tDIV B\n\tPUSH A\n"); }
	| exp3 { $<valor>$ = $<valor>1; }
	;
exp3:
 	exp3 '^' exp4 { $<valor>$ = pow($<valor>1,$<valor>3); 
			printf("\tPOP B\n\tPOP C\n\tMOV A, C\n.loop%d:\n\tMUL C\n\tDEC B\n\tCMP B, 1\n\tJNE .loop%d\n\tPUSH A\n", count, count); 
			count++; }
	| exp4 { $<valor>$ = $<valor>1;}
	;

exp4:
	'(' exp1 ')' { $<valor>$ = $<valor>2; }
	| NUM { $<valor>$ = $<valor>1; 
		printf ("\tPUSH %d\n", $<valor>1); }
	| VAR { char name = $<rotulo>1;
		$<valor>$ = mem[name-'a']; 
		if(flag[$<rotulo>1-'a']) 
			printf("\tMOV C, v%c\n\tPUSH [C]\n", name ); 
		else{ 
			printf("; "); 
			yyerror("Variavel nao declarada"); } }
	;



%%

void yyerror(char *s) {
	printf("ERRO: %s\n", s);
}

int main() {
	printf("; ");
  	yyparse();
    	return 0;
}
