# Circuitos Digitais 🤖

A disciplina de Circuitos Digitais é fundamental no estudo da Ciência da Computação,
seu principal objetivo é estimular no aluno a capacidade de projetar e analisar sistemas que
processam informações. Dentro deste contexto de aprendizado e ensino, o docente responsável por ministrar a
disciplina, propôs aos seus alunos a implementação de um projeto de máquina de vender salgados com o intuito de reforçar
o aprendizado e expandir os limites dos discentes em relação ao assunto. Foi definido que a máquina deveria possuir em
seu funcionamento, lógica e tratamento de problemas relacionados a compra e venda dos
salgados e o projeto deveria ser produzido na linguagem VHDL.

## Descrição das operações da máquina 🍔
### O Cliente escolhe qual o tipo de salgado ele deseja
| **Tipo do salgado**    | **Preço**   |
-------------------------|-------------|
| **Bata frita grande**  | **R$ 2,50** |
| **Bata frita média**   | **R$ 1,50** |
| **Bata frita pequena** | **R$ 0,75** |
| **Tortilha Grande**    | **R$ 3,50** |
| **Tortilha pequena**   | **R$ 2,00** |

### Moedas aceitas 💰
R$ 0.25, R$ 0.50 e R$ 1.00

## Regras da máquina 📝
Se não houver estoque do salgado escolhido então a máquina emite um aviso, caso houve estoque do salgado escolhido, então a máquina permite que o cliente comece a colocar as moedas e
caso o cliente colocar alguma moeda não permitida então a máquina não realiza a soma e deixa a moeda passar direto para a saída. Até que a soma seja completada
o cliente pode desistir a qualquer momento da compra. Se isso ocorrer, todas as moedas que ele depositou devem ser devolvidas, e o somatório do valor depositado deve ser exibido nos displays
de 7 segmentos.
