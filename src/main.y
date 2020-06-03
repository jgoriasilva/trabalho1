

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

	/* Toda entrada dada a calculadora é uma sequência de expressões matemáticas ou comandos que atribuem valores a variaveis, cada um separado por um caracter \n */

S:
 	S exp1 EOL { 	printf("\tPOP A\n; Resultado: %d\n; ", $<valor>2); }
	| S C EOL { printf("\n; "); }
 	|
	;


	/* Os comandos aceitos são do tipo 'variavel' = 'expressão'. Um exemplo aceito é "a = (5+5)*4/2". Outro, "a=a+2*b", desde que a e b estejam previamente definidos */

C:
 	VAR '=' exp1 {	char name = $<rotulo>1;
			mem[name-'a'] = $<valor>3; 
			if(!flag[name-'a']) {
				printf("\tJMP jump%c\nv%c:\njump%c:\n\tMOV C, v%c\n\tPOP A\n\tMOV [C], A\n", name, name, name, name); 
				flag[name-'a'] = 1; }
			else
				printf("\tMOV C, v%c\n\tPOP A\n\tMOV [C], A\n", name); }
	;

	/* Para a resolução das expressões matemáticas, foi implementado um sistema de prioridade de certas expressões sobre outras. Aqui, está implementada a expressão de mais baixo nível, chamada de exp1. Ela é composta pela operação de adição, que deve sempre ser resolvida por último. 'exp1' pode também gerar uma expressão imediatamente maior; no caso, 'exp2'.*/

exp1:
	exp1 '+' exp2 {	$<valor>$ = $<valor>1 + $<valor>3; 
			printf("\tPOP A\n\tPOP B\n\tADD A, B\n\tPUSH A\n"); }
	| exp2 { $<valor>$ = $<valor>1; }
	;

	/* O próximo nível de prioridade é composto pelas operações de multiplicação e divisão, que devem ser resolvidos antes da operação de adição porém depois das operações de níveis maiores. 'exp2' pode também gerar uma expressão de nível maior, chamada de 'exp3'. */

exp2:
	exp2 '*' exp3 {	$<valor>$ = $<valor>1 * $<valor>3; 
			printf("\tPOP A\n\tPOP B\n\tMUL B\n\tPUSH A\n"); }
	| exp2 '/' exp3 {	$<valor>$ = $<valor>1 / $<valor>3; 
				printf("\tPOP B\n\tPOP A\n\tDIV B\n\tPUSH A\n"); }
	| exp3 { $<valor>$ = $<valor>1; }
	;

	/* Em seguida, tem-se o nível de prioridade 3, chamado de 'exp3'. Aqui, encontra-se a operação de potenciação. Esse nível também pode gerar expressões de nível 4, chamadas de 'exp4'. */

exp3:
 	exp3 '^' exp4 { $<valor>$ = pow($<valor>1,$<valor>3); 
			printf("\tPOP B\n\tPOP C\n\tMOV A, C\n.loop%d:\n\tMUL C\n\tDEC B\n\tCMP B, 1\n\tJNE .loop%d\n\tPUSH A\n", count, count); 
			count++; }
	| exp4 { $<valor>$ = $<valor>1;}
	;

	/* Por fim, o nível de maior prioridade, que deve ser resolvido antes. Aqui, estão os parênteses e os tokens finais NUM e VAR. A 'exp4' não gera nenhuma outra expressão de maior nível de prioridade. */

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
