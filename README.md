# EA876 - Trabalho 1

Este trabalho tem como objetivo a implementação de um programa que converte expressões matemáticas para um código assembly equivalente.

## Descrição

Ao ser executado, o código espera a inserção por parte do usuário de uma expressão matemática a ser convertida para um código assembly executável no simulador online disponível em [schweigi-simulator](https://schweigi.github.io/assembler-simulator).

## Utilização

### Dependências

Para o correto funcionamento do programa, é necessário possuir make, bison e flex.

### Executando o programa

A execução do programa é bem simples. Para executá-lo, basta digitar o comando 'make run' enquanto na pasta root do programa.

### Durante a execução

Depois de digitar o comando 'make run' no terminal, o programa será executado. O usuário deve então simplesmente digitar alguma expressão matemática cuja conversão para código assembly é desejada. As expressões podem ser dos seguintes tipos:

* Atribuição de valor a variável: 'VAR' = 'EXPRESSÃO'. Um exemplo deste caso é a seguinte expressão: "a = 5+3". As variáveis são letras de a-z, minúsculas. Uma expressão válida também é, por exemplo, "a = a+1", desde que "a" já tenha recebido um valor anteriormente.
* Expressão matemática pura, com resultado retornando para o registrador A. Neste caso, o usuário pode digitar qualquer expressão matemática que possua as operações de adição '+', multiplicação '\*', divisão '/' e potenciação '^'. Também é possível a utilização de parênteses '(' e ')'. O usuário pode também utilizar uma variável com valor previamente atribuído como operando de qualquer operação. Um exemplo: "2+a\*(b/3)+(b^2)".

### Resultado

O programa irá então printar o código assembly a ser executado no simulador supracitado para a execução da expressão matemática inserida pelo usuário. Para maior conforto do usuário, o código gerado apresenta as expressões inseridas como comentários para o código assembly, bem como o resultado final da expressão. Assim sendo, o usuário precisa simplesmente copiar todo o texto imprimido na tela e colá-lo no simulador para que a execução seja feita.

## Autor

João Antônio Gória Silva -- jgoriasilva@gmail.com
