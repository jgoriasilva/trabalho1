/*

Código: main.y
Objetivo: Implementar a gramática responsável por compilar expressões matemáticas em um código assembly
Entradas: Expressões matemáticas digitadas pelo usuário
Saída: Este código "printa" o código assembly gerado pela expressão matemática digitada pelo usuário
Nome: João Antônio Gória Silva
RA: 199567

*/

%{
#include <stdio.h>
#include <stdlib.h>
#include "math.h"
void yyerror(char *c);
int yylex(void);

/* Esta variável é utilizada para que cada operação de potencialização tenha seu próprio rótulo. */
int count=0;

/* Vetor que armazena os valores das variáveis para o código em C. As variáveis são posteriormente armazenadas em lugares da memória utilizando o código assembly. */
int mem[26];

/* Vetor que guarda uma flag para cada uma das variáveis, a ser explorado posteriormente no comando de atribuição de valores a variáveis. */
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

	/* Toda entrada da a calculadora é uma sequência de expressões matemáticas ou comandos que atribuem valores a variaveis, cada um separado por um caracter \n */

S:
 	S exp1 EOL { 	printf("\tPOP A\n; Resultado: %d\n; ", $<valor>2); }
	| S C EOL { printf("\n; "); }
	|
	;


	/* Os comandos aceitos são do tipo 'variavel' = 'expressão'. Um exemplo aceito é "a = (5+5)*4/2". Outro, "a=a+2*b", desde que a e b estejam previamente definidos */

C:
 	/* Para atribuição de valores a variáveis, existem dois casos:
	1. É a primeira vez que tal variável aparece: Neste caso, o código irá alocar um espaço da mémoria para a variável 'VAR' e irá armazenar neste local o valor 'exp1' desejado pelo usuário.
	2. A variável já teve previamente um valor atribuído a ela: Neste caso, o código irá simplesmente buscar a posição de memória onde a variável 'VAR' foi armazenada e irá substituir o valor lá alocado pelo novo valor 'exp1'.
	A identificação do caso é feita de forma individual para cada variável. Todas as variáveis começam com sua posição no vetor 'flag' em 0. Assim, elas sempre irão cair no primeiro caso na primeira execução. Depois, elas tem sua posição no vetor 'flag' atualizada para 1, e então só passam a cair no segundo caso. */

 	VAR '=' exp1 {	char name = $<rotulo>1; /* Recebe o nome da variável e atribui a variável 'name' */
			mem[name-'a'] = $<valor>3;  /* O vetor 'mem' recebe o valor da variável na posição relativa da variável e.g. a variável a tem posição relativa 0, b tem posição relativa 1 e assim sucessivamente até a variável z. */
			if(!flag[name-'a']) { /* Verifica em qual caso (explicado anteriormente) tal variável se encaixa, a partir do vetor 'flag'. */
				printf("\tJMP jump%c\nv%c:\njump%c:\n\tMOV C, v%c\n\tPOP A\n\tMOV [C], A\n", name, name, name, name); /* Aqui, é implementada a primeira alocação da variável. Para isso, primeiro dá-se o comando JMP jump'name', para que o código prossiga com a sua execução. Depois, aloca-se um espaço de memória para a variável v'name'. Cria-se então o rótulo jump'name' que é exatamente para onde o código pula com o comando JMP jump'name'. Depois, busca-se o endereço alocado de memória para v'name' e atribui seu endereço no registrador C. Então, o valor desejado para a atribuição é colocado na pilha e finalmente passado para o endereço apontado por C. Assim, a variável tem um espaço de memória reservado e seu valor está atribuído. */
				flag[name-'a'] = 1; } /* Atualiza-se o valor da flag de tal variável para que ela passe a cair no segundo caso. */
			else
				printf("\tMOV C, v%c\n\tPOP A\n\tMOV [C], A\n", name); } /* Caso a variável caia no segundo caso, simplesmente pega-se o endereço reservado para a variável, coloca-lhe no registrador C e então move-se o valor desejado de atribuição para o endereço apontado por C. */
	;

	/* Para a resolução das expressões matemáticas, foi implementado um sistema de prioridade de certas expressões sobre outras. Aqui, está implementada a expressão de mais baixo nível, chamada de exp1. Ela é composta pela operação de adição, que deve sempre ser resolvida por último. 'exp1' pode também gerar uma expressão imediatamente maior; no caso, 'exp2'.*/

exp1:
	exp1 '+' exp2 {	$<valor>$ = $<valor>1 + $<valor>3; 
			printf("\tPOP A\n\tPOP B\n\tADD A, B\n\tPUSH A\n"); } /* Para resolução da expressão, simplesmente puxa-se o valor de ambas as expressões para os registradores A e B e então soma-se os valores de A e B e armazena-lhe no registrador A. O valor de A é então subido para a pilha.*/
	| exp2 { $<valor>$ = $<valor>1; }
	;

	/* O próximo nível de prioridade é composto pelas operações de multiplicação e divisão, que devem ser resolvidos antes da operação de adição porém depois das operações de níveis maiores. 'exp2' pode também gerar uma expressão de nível maior, chamada de 'exp3'. */

exp2:
	exp2 '*' exp3 {	$<valor>$ = $<valor>1 * $<valor>3; 
			printf("\tPOP A\n\tPOP B\n\tMUL B\n\tPUSH A\n"); } /* A resolução de multiplicações é exatamente igual a resolução de uma adição, com a diferença que, ao invés dos valores serem somados, eles são multiplicados. */
	| exp2 '/' exp3 {	$<valor>$ = $<valor>1 / $<valor>3;
				printf("\tPOP B\n\tPOP A\n\tDIV B\n\tPUSH A\n"); } /* De maneira similar, a divisão é resolvida de forma semelhante a multiplicação, porém com os valores sendo dividos. */
	| exp3 { $<valor>$ = $<valor>1; }
	;

	/* Em seguida, tem-se o nível de prioridade 3, chamado de 'exp3'. Aqui, encontra-se a operação de potenciação. Esse nível também pode gerar expressões de nível 4, chamadas de 'exp4'. */
	/* A potenciação é resolvida primeiramente puxando-se os valores de 'exp3' e 'exp4' para os registradores C e B, respectivamente. Então, verifica-se se B (o expoente) é igual a 0. Se for o caso, o programa pula para o rótulo .zero'count' (o count é um contador que incrementa a cada operação de exponenciação para que o código não retorne a loops errados). Neste rótulo, o registrador A recebe o valor 1 e então o código segue para o rótulo .end'count'. Isto ocorre porque qualque número elevado a 0 deve retornar 1 como resultado. Caso o expoente não seja 0, então o código segue para o rótulo .nzero'count'. Lá, é implementado um loop (com rótulo .loop'count') para que B seja decrementado e A seja multiplicado sucessivamente por C até que B seja igual a 1. Isto implementa exatamente a operação de potenciação. Depois, o código segue naturalmente para o rótulo .end'count' onde o resultado armazenado em A é "empurrado" para a pilha. */

exp3:
 	exp3 '^' exp4 { $<valor>$ = pow($<valor>1,$<valor>3); 
			printf("\tPOP B\n\tPOP C\n\tCMP B,0\n\tJE .zero%d\n\tJNE .nzero%d\n.zero%d:\n\tMOV A, 1\n\tJMP .end%d\n.nzero%d:\n\tMOV A, C\n.loop%d:\n\tMUL C\n\tDEC B\n\tCMP B, 1\n\tJNE .loop%d\n.end%d:\n\tPUSH A\n", count, count, count, count, count, count, count, count); 
			count++; }
	| exp4 { $<valor>$ = $<valor>1;}
	;

	/* Por fim, o nível de maior prioridade, que deve ser resolvido antes. Aqui, estão os parênteses e os tokens finais NUM e VAR. A 'exp4' não gera nenhuma outra expressão de maior nível de prioridade. */

exp4:
	'(' exp1 ')' { $<valor>$ = $<valor>2; } /* Os parênteses simplesmente geram uma expressão nova. Observe que, como eles tem uma prioridade de nível 4, eles sempre serão resolvidos primeiro pois o analisador léxico identificará esta expressão exp1 primeiro do que a exp1 inserida pelo usuário. */
	| NUM { $<valor>$ = $<valor>1; 
		printf ("\tPUSH %d\n", $<valor>1); } /* Empurra o valor de NUM para a pilha. */
	| VAR { char name = $<rotulo>1;
		$<valor>$ = mem[name-'a']; 
		if(flag[$<rotulo>1-'a']) 
			printf("\tMOV C, v%c\n\tPUSH [C]\n", name ); /* Para uma váriavel, deve-se acessar a posição de memória e então empurrar para a pilha o valor armazenado nesta posição. */
		else{ 
			printf("; "); 
			yyerror("Variavel nao declarada. Por favor, primeiro atribua um valor a esta variável utilizando o comando VAR = NUM. "); } } /* Caso a variável ainda não tenha tido um valor atribuído a ela (não-declarada), o programa retorna um erro. */
	;

%%

/* O código pode retornar um erro. Um exemplo é quando o usuário tenta utilizar uma variável que não teve valor atribuído previamente. */

void yyerror(char *s) {
	printf("ERRO: %s\n", s);
}

int main() {
	/* Inicializa os registradores e prepara a interface para recebimento de uma expressão matemática. */
	printf("; Inicialização dos registradores");
	printf("\n\tMOV A, 0\n\tMOV B, 0\n\tMOV C, 0\n\tMOV D, 0\n");
	printf("; ");
  	yyparse();
    	return 0;
}
