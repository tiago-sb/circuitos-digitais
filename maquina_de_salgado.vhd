-------------------------------------------------------------------------------------------------------------------
-- Nome: Projeto de Circuitos Digitais
-- Autores: Tiago Santos Bela e Brener Gomes dos Santos 
-- Funcao: Mostrar o funcionamento de um maquina de vender salgados utilizando os fundamentos dos circuitos digitais e VHDL
-- Inicio: 17/06/2024
-- Termino: 09/07/2024
-------------------------------------------------------------------------------------------------------------------

-- Bibliotecas e pacotes
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Entidade
-- definicao da estrutura dos pinos do projeto
ENTITY maquina_de_salgado IS 
	PORT(
		clk                          : IN STD_LOGIC; -- clock geral da aplicacao
		rst                          : IN STD_LOGIC; -- pino necessario para efetuar o reset da maquina
		ligar_maquina                : IN STD_LOGIC; -- pino que eh uma abstracao do processo de iniciar a maquina
		estados_atual_maquina        : OUT STD_LOGIC_VECTOR(2 downto 0); -- estado atual da maquina
		continuar                    : IN STD_LOGIC; -- continuar o percurso da maquina

		-- pinos para a selecao do salgado
		salgado_escolhido            : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- vetor com o tipo do salgado escolhido
		liberar_salgado              : IN STD_LOGIC; -- pino para liberar o salgado para o cliente 
		confirmar_salgado            : IN STD_LOGIC; -- pino para efetuar a confirmacao do salgado escolhido
		salgado_invalido_led         : OUT STD_LOGIC; -- led que simboliza que o salgado escolhido foi invalido
		salgado_terminado_led        : OUT STD_LOGIC; -- led que simboliza que o salgado escolhido esta sem estoque	
		salgado_liberado_cliente_led : OUT STD_LOGIC; -- led que simboliza que o salgado foi liberado para o cliente
		valor_salgado                : BUFFER INTEGER RANGE 0 TO 999 := 0; -- contem o valor do salgado escolhido
		
		-- pinos para o pagamento
		confirmar_moeda              : IN STD_LOGIC; -- pino necessario para efetuar a confirmacao de moeda 
		moedas                       : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- vetor com os tipos de moedas aceitas
		moeda_invalida_led           : OUT STD_LOGIC; -- pino de aviso para moedas invalidas
		moeda_liberada_cliente_led   : OUT STD_LOGIC; -- pino de avso para liberacao de moedas para o cliente
		quantia_inserida             : BUFFER INTEGER RANGE 0 TO 999; -- quantia inserida pelo cliente para a compra do salgado
		troco_cliente                : BUFFER INTEGER RANGE 0 TO 999 := 0; -- troco para o cliente
		
		-- pinos para os leds dos estados
		estado_inicial_led           : OUT STD_LOGIC; -- led do estado inicial
		estado_escolha_salgado_led   : OUT STD_LOGIC; -- led do estado de escolha
		estado_estoque_led           : OUT STD_LOGIC; -- led do estado de estoque
		estado_pagamento_led         : OUT STD_LOGIC; -- led do estado de pagamento
		estado_liberar_salgado_led   : OUT STD_LOGIC; -- led do estado de liberar salgado
		estado_troco_led             : OUT STD_LOGIC; -- led do estado de troco

		-- display de 7 segmentos
		display7_salgado             : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- saida para o display do tipo do salgado
		display7_quantia_centena     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- saida para o display do algarismo da centena da moeda
		display7_quantia_dezena      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- saida para o display do algarismo da dezena da moeda
		display7_quantia_unidade     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- saida para o display do algarismo da unidade da moeda
	);  
END ENTITY maquina_de_salgado;

-- Arquitetura
-- definicao da estrutura logica de como o circuito vai funcionar
ARCHITECTURE maquina OF maquina_de_salgado IS
	-- setando um type de estados, para poder manipular a maquina de forma eficiente 
	TYPE estado_maquina IS (estado_inicial, estado_escolha_salgado, estado_estoque, estado_pagamento, estado_liberar_salgado, estado_troco);

	-- sinais relativos aos estados da maquina
	SIGNAL estado_atual: estado_maquina; -- sinal que recebe o estado atual da maquina
	SIGNAL proximo_estado: estado_maquina; -- sinal que recebe o proximo estado da maquina
	
	-- sinais relativos aos estoques dos salgados 
   SIGNAL estoque_batata_frita_grande  : INTEGER RANGE 0 TO 10 := 5; -- estoque de batata frita grande = 5 unidades 
   SIGNAL estoque_batata_frita_media   : INTEGER RANGE 0 TO 10 := 5; -- estoque de batata frita media = 5 unidades 
   SIGNAL estoque_batata_frita_pequena : INTEGER RANGE 0 TO 10 := 5; -- estoque de batata frita pequena = 5 unidades 
   SIGNAL estoque_tortilha_grande      : INTEGER RANGE 0 TO 10 := 5; -- estoque de tortilha grande = 5 unidades 
   SIGNAL estoque_tortilha_pequena     : INTEGER RANGE 0 TO 10 := 5; -- estoque de tortilha pequena = 5 unidades 
	 
	------------------------------------------------------------------------------------------------
	-- Nome: mostrarDisplay7
	-- Funcao: receber um numero inteiro e o converter para ser utilizado no display de 7 segmentos
	------------------------------------------------------------------------------------------------
	FUNCTION mostrarDisplay7(numeroEscolhido: INTEGER) RETURN STD_LOGIC_VECTOR IS
	VARIABLE saidaDisplay: STD_LOGIC_VECTOR(6 DOWNTO 0); 
	BEGIN 
		CASE(numeroEscolhido) IS
			WHEN 0 => saidaDisplay      := "1000000"; -- caso 0
			WHEN 1 => saidaDisplay      := "1111001"; -- caso 1  
			WHEN 2 => saidaDisplay      := "0100100"; -- caso 2
			WHEN 3 => saidaDisplay      := "0110000"; -- caso 3
			WHEN 4 => saidaDisplay      := "0011001"; -- caso 4
			WHEN 5 => saidaDisplay      := "0010010"; -- caso 5
			WHEN 6 => saidaDisplay      := "0000010"; -- caso 6
			WHEN 7 => saidaDisplay      := "1111000"; -- caso 7
			WHEN 8 => saidaDisplay      := "0000000"; -- caso 8
			WHEN 9 => saidaDisplay      := "0010000"; -- caso 9  
			WHEN 10 => saidaDisplay     := "0001000"; -- caso A  
			WHEN 11 => saidaDisplay     := "0000011"; -- caso B  
			WHEN 12 => saidaDisplay     := "1000110"; -- caso C  
			WHEN 13 => saidaDisplay     := "0100001"; -- caso D  
			WHEN 14 => saidaDisplay     := "0000110"; -- caso E  
			WHEN OTHERS => saidaDisplay := "1111111"; -- nao se aplica a nenhum caso, display zerado
		END CASE;
	RETURN saidaDisplay; 
	END mostrarDisplay7; 

BEGIN
	------------------------------------------------------------------------------------------------
	-- Nome: TROCA_DE_ESTADO	
	-- PROCESSO SENSIVEL AO CLOCK
	-- Funcao: processo sensa­vel ao clock, e a cada borda de subida da onda o estado eh atualizado 
	------------------------------------------------------------------------------------------------
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			estado_atual <= proximo_estado;
		END IF;
	END PROCESS;
	
	------------------------------------------------------------------------------------------------
	-- Nome: EXIBIR_FUNCOES
	-- PROCESSO SENSIVEL AO CLOCK
	-- Funcao: processo que sera o responsavel por controlar atualizacao das informacoes exibidas nos displays de 7 segmentos
	------------------------------------------------------------------------------------------------
	PROCESS (clk)
	VARIABLE numero_salgado: integer range 0 to 999;
	BEGIN
		IF (clk'event AND clk = '1') THEN
			CASE (estado_atual) IS
				WHEN estado_inicial => 
					display7_salgado         <= "1111111"; -- display desligado
					display7_quantia_centena <= "1111111"; -- display desligado
					display7_quantia_dezena  <= "1111111"; -- display desligado
					display7_quantia_unidade <= "1111111"; -- display desligado
				WHEN estado_escolha_salgado =>
					CASE (salgado_escolhido) IS
						WHEN "001" => -- selecionou o salgado tipo 1 (batata frita grande) R$ 2,50
							display7_salgado         <= mostrarDisplay7(10); -- salgado A
							display7_quantia_centena <= mostrarDisplay7(2);
							display7_quantia_dezena  <= mostrarDisplay7(5);
							display7_quantia_unidade <= mostrarDisplay7(0);
							numero_salgado           := 1;
							valor_salgado            <= 250;
						WHEN "010" => -- selecionou o salgado tipo 2 (batata frita media) R$ 1,50
							display7_salgado         <= mostrarDisplay7(11); -- salgado B
							display7_quantia_centena <= mostrarDisplay7(1);
							display7_quantia_dezena  <= mostrarDisplay7(5);
							display7_quantia_unidade <= mostrarDisplay7(0);
							numero_salgado           := 2;
							valor_salgado            <= 150;
						WHEN "011" => -- selecionou o salgado tipo 3 (batata frita pequena) R$ 0,75
							display7_salgado         <= mostrarDisplay7(12); -- salgado C
							display7_quantia_centena <= mostrarDisplay7(0);
							display7_quantia_dezena  <= mostrarDisplay7(7);
							display7_quantia_unidade <= mostrarDisplay7(5);
							numero_salgado           := 3;
							valor_salgado            <= 75;
						WHEN "100" => -- selecionou o salgado tipo 4 (tortilha grande) R$ 3,50
							display7_salgado         <= mostrarDisplay7(13); -- salgado D
							display7_quantia_centena <= mostrarDisplay7(3);
							display7_quantia_dezena  <= mostrarDisplay7(5);
							display7_quantia_unidade <= mostrarDisplay7(0);
							numero_salgado           := 4;
							valor_salgado            <= 350;
						WHEN "101" => -- selecionou o salgado tipo 5 (tortilha pequena) R$ 2,00
							display7_salgado         <= mostrarDisplay7(14); -- salgado E
							display7_quantia_centena <= mostrarDisplay7(2);
							display7_quantia_dezena  <= mostrarDisplay7(0);
							display7_quantia_unidade <= mostrarDisplay7(0);
							numero_salgado           := 5;
							valor_salgado            <= 200;
						WHEN others => -- selecionou o salgado um tipo fora do intervalo
							display7_salgado         <= mostrarDisplay7(0);
							display7_quantia_centena <= mostrarDisplay7(0);
							display7_quantia_dezena  <= mostrarDisplay7(0);
							display7_quantia_unidade <= mostrarDisplay7(0);
							numero_salgado           := 0;
							valor_salgado            <= 0;
					END CASE;
				WHEN estado_estoque =>
					display7_salgado         <= mostrarDisplay7(numero_salgado);
					display7_quantia_centena <= mostrarDisplay7((quantia_inserida / 100) mod 10);
					display7_quantia_dezena  <= mostrarDisplay7((quantia_inserida mod 100) / 10);
					display7_quantia_unidade <= mostrarDisplay7(quantia_inserida mod 10);
				WHEN estado_pagamento =>
					display7_salgado         <= mostrarDisplay7(numero_salgado);
					display7_quantia_centena <= mostrarDisplay7((quantia_inserida / 100) mod 10);
					display7_quantia_dezena  <= mostrarDisplay7((quantia_inserida mod 100) / 10);
					display7_quantia_unidade <= mostrarDisplay7(quantia_inserida mod 10);
				WHEN estado_liberar_salgado =>
					display7_salgado         <= mostrarDisplay7(numero_salgado);
					display7_quantia_centena <= mostrarDisplay7((troco_cliente / 100) mod 10);
					display7_quantia_dezena  <= mostrarDisplay7((troco_cliente mod 100) / 10);
					display7_quantia_unidade <= mostrarDisplay7(troco_cliente mod 10);
				WHEN estado_troco =>
					display7_salgado         <= mostrarDisplay7(numero_salgado);
					display7_quantia_centena <= mostrarDisplay7((troco_cliente / 100) mod 10);
					display7_quantia_dezena  <= mostrarDisplay7((troco_cliente mod 100) / 10);
					display7_quantia_unidade <= mostrarDisplay7(troco_cliente mod 10);
			END CASE;
		END IF;
	END PROCESS;

	------------------------------------------------------------------------------------------------
	-- nome: ADICAO_DE_MOEDAS
	-- PROCESSO SENSIVEL AO CLOCK E A OUTROS PINOS DA MAQUINA
	-- Funcao: processo que sera o responsavel por controlar a adicao de moedas do cliente 
	------------------------------------------------------------------------------------------------
	PROCESS (clk, moedas, confirmar_moeda)
	BEGIN
		IF (clk = '1' AND estado_atual = estado_inicial) THEN
			moeda_invalida_led <= '0';
			quantia_inserida <= 0;
		ELSE 
			IF ((confirmar_moeda'event AND confirmar_moeda = '0') AND (estado_atual = estado_pagamento)) THEN
				CASE (moedas) IS
					WHEN "011" =>
						moeda_invalida_led <= '0'; -- pino sem alertar nada
						quantia_inserida <= quantia_inserida + 25; -- mais R$ 0,25
					WHEN "101" =>
						moeda_invalida_led <= '0'; -- pino sem alertar nada
						quantia_inserida <= quantia_inserida + 50; -- mais R$ 0,50
					WHEN "001" =>
						moeda_invalida_led <= '0'; -- pino sem alertar nada
						quantia_inserida <= quantia_inserida + 100; -- mais R$ 1,00
					WHEN OTHERS =>
						moeda_invalida_led <= '1'; -- pino faz sinal de alerta
				END CASE;
			END IF;
		END IF;
	END PROCESS;

	------------------------------------------------------------------------------------------------
	-- Nome: LOGICA_DE_ESTADOS
	-- PROCESSO SENSIVEL AO CLOCK E AO RESET
	-- Funcao: processo que sera o responsavel por controlar toda a logica de funcionamento dos estados da maquina
	------------------------------------------------------------------------------------------------
	PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN 
			estados_atual_maquina      <= "000";
			estado_inicial_led         <= '1'; -- led do estado inicial ligado
			estado_escolha_salgado_led <= '0'; 
			estado_estoque_led         <= '0'; 
			estado_pagamento_led       <= '0'; 
			estado_liberar_salgado_led <= '0'; 
			estado_troco_led           <= '0'; 
			salgado_terminado_led      <= '0';
			salgado_invalido_led       <= '0';
			moeda_liberada_cliente_led <= '0';
			troco_cliente              <= 0;
			estoque_batata_frita_grande  <= 5; -- estoque de batata frita grande = 5 unidades 
   		estoque_batata_frita_media   <= 5; -- estoque de batata frita media = 5 unidades 
   		estoque_batata_frita_pequena <= 5; -- estoque de batata frita pequena = 5 unidades 
   		estoque_tortilha_grande      <= 5; -- estoque de tortilha grande = 5 unidades 
			estoque_tortilha_pequena     <= 5; -- estoque de tortilha pequena = 5 unidades
			proximo_estado <= estado_inicial;
		ELSE
			CASE (estado_atual) IS
				WHEN estado_inicial => -- comecar a maquina
					estados_atual_maquina      <= "001";
					estado_inicial_led         <= '1'; -- led do estado inicial ligado
					estado_escolha_salgado_led <= '0';
					estado_estoque_led         <= '0';
					estado_pagamento_led       <= '0';
					estado_liberar_salgado_led <= '0';
					estado_troco_led           <= '0';
					troco_cliente <= 0;
					IF (ligar_maquina = '1') THEN
						salgado_terminado_led <= '0';
						salgado_invalido_led  <= '0';
						proximo_estado <= estado_escolha_salgado;
					ELSE 
						proximo_estado <= estado_inicial;
					END IF;
				WHEN estado_escolha_salgado => -- escolher o tipo do salgado
					estados_atual_maquina      <= "010";
					estado_inicial_led         <= '0'; 
					estado_escolha_salgado_led <= '1'; -- led do estado de escolher salgado ligado
					estado_estoque_led         <= '0';
					estado_pagamento_led       <= '0';
					estado_liberar_salgado_led <= '0';
					estado_troco_led           <= '0';

					IF (confirmar_salgado = '0') THEN
						IF (salgado_escolhido = "001" OR salgado_escolhido = "010" OR salgado_escolhido = "011" OR salgado_escolhido = "100" OR salgado_escolhido = "101") THEN
							proximo_estado <= estado_estoque;
							salgado_terminado_led <= '0';
							salgado_invalido_led  <= '0';
						ELSE
							salgado_invalido_led <= '1'; -- salgado escolhido invalido
							proximo_estado <= estado_escolha_salgado;
						END IF;
					ELSE
						salgado_terminado_led <= '0';
						salgado_invalido_led  <= '0';
						proximo_estado <= estado_escolha_salgado;
					END IF;	
				WHEN estado_estoque =>	-- verificar se ha salgados no estoque
					estados_atual_maquina      <= "011";
					estado_inicial_led         <= '0'; 
					estado_escolha_salgado_led <= '0';
					estado_estoque_led         <= '1'; -- led do estado de verificar o estoque do salgado ligado
					estado_pagamento_led       <= '0';
					estado_liberar_salgado_led <= '0';
					estado_troco_led           <= '0';
					salgado_invalido_led       <= '0';

					CASE (salgado_escolhido) IS
						WHEN "001" =>
							IF (estoque_batata_frita_grande > 0) THEN
								salgado_terminado_led <= '0'; 
								proximo_estado <= estado_pagamento; -- como tem estoque para o salgado selecionado o usuario pode fazer o pagamento
							ELSE
								salgado_terminado_led <= '1'; -- led para simbolizar que nao ha estoque do salgado selecionado
								proximo_estado <= estado_inicial; -- nao ha estoque, volta para o estado inicial
							END IF;
						WHEN "010" =>
							IF (estoque_batata_frita_media > 0) THEN
								salgado_terminado_led <= '0'; 
								proximo_estado <= estado_pagamento; -- como tem estoque para o salgado selecionado o usuario pode fazer o pagamento
							ELSE
								salgado_terminado_led <= '1'; -- led para simbolizar que nao ha estoque do salgado selecionado
								proximo_estado <= estado_inicial; -- nao ha estoque, volta para o estado inicial
							END IF;
						WHEN "011" =>
							IF (estoque_batata_frita_pequena > 0) THEN
								salgado_terminado_led <= '0'; 
								proximo_estado <= estado_pagamento; -- como tem estoque para o salgado selecionado o usuario pode fazer o pagamento
							ELSE
								salgado_terminado_led <= '1'; -- led para simbolizar que nao ha estoque do salgado selecionado
								proximo_estado <= estado_inicial; -- nao ha estoque, volta para o estado inicial
							END IF;
						WHEN "100" =>
							IF (estoque_tortilha_grande > 0) THEN
								salgado_terminado_led <= '0'; 
								proximo_estado <= estado_pagamento; -- como tem estoque para o salgado selecionado o usuario pode fazer o pagamento
							ELSE
								salgado_terminado_led <= '1'; -- led para simbolizar que nao ha estoque do salgado selecionado
								proximo_estado <= estado_inicial; -- nao ha estoque, volta para o estado inicial
							END IF;
						WHEN "101" =>
							IF (estoque_tortilha_pequena > 0) THEN
								salgado_terminado_led <= '0'; 
								proximo_estado <= estado_pagamento; -- como tem estoque para o salgado selecionado o usuario pode fazer o pagamento
							ELSE
								salgado_terminado_led <= '1'; -- led para simbolizar que nao ha estoque do salgado selecionado
								proximo_estado <= estado_inicial; -- nao ha estoque, volta para o estado inicial
							END IF;
						WHEN OTHERS => 
							salgado_invalido_led <= '1'; -- pino do salgado invalido
							proximo_estado <= estado_escolha_salgado; -- volta para o estado de selecionar salgado
					END CASE;
				WHEN estado_pagamento => -- efetuar o pagamento do salgado
					estados_atual_maquina      <= "100";
					estado_inicial_led         <= '0'; 
					estado_escolha_salgado_led <= '0';
					estado_estoque_led         <= '0';
					estado_pagamento_led       <= '1'; -- led do estado de pagamento ligado
					estado_liberar_salgado_led <= '0';
					estado_troco_led           <= '0';
					salgado_terminado_led      <= '0';

					IF (quantia_inserida >= valor_salgado) THEN
						proximo_estado <= estado_liberar_salgado;
					ELSIF (rst = '0') THEN
						proximo_estado <= estado_troco;
					END IF;	
				WHEN estado_liberar_salgado =>
					estados_atual_maquina      <= "101";
					estado_inicial_led         <= '0'; 
					estado_escolha_salgado_led <= '0';
					estado_estoque_led         <= '0';
					estado_pagamento_led       <= '0'; 
					estado_liberar_salgado_led <= '1'; -- led do estado de liberar salgado ligado
					estado_troco_led           <= '0';
					salgado_liberado_cliente_led <= '1';
					IF (liberar_salgado = '1') THEN
						CASE (salgado_escolhido) IS      
							WHEN "001" =>
								estoque_batata_frita_grande <= estoque_batata_frita_grande - 1;
							WHEN "010" =>
								estoque_batata_frita_media <= estoque_batata_frita_media - 1;
							WHEN "011" =>
								estoque_batata_frita_pequena <= estoque_batata_frita_pequena - 1;
							WHEN "100" =>
								estoque_tortilha_grande <= estoque_tortilha_grande - 1; 
							WHEN "101" =>
								estoque_tortilha_pequena <= estoque_tortilha_pequena - 1;
							WHEN OTHERS =>
						END CASE;
						troco_cliente <= quantia_inserida - valor_salgado; -- calculo do troco a ser devolvido
						IF (troco_cliente = 0) THEN
							proximo_estado <= estado_inicial; -- caso nao tenha troco volta para o estado inicial
						ELSE
							proximo_estado <= estado_troco; -- caso tenha troco vai para o estado de devolver o troco
						END IF;
					ELSE 
						proximo_estado <= estado_liberar_salgado;
					END IF;
				WHEN estado_troco =>
					estados_atual_maquina      <= "110";
					estado_inicial_led           <= '0'; 
					estado_escolha_salgado_led   <= '0';
					estado_estoque_led           <= '0';
					estado_pagamento_led         <= '0'; 
					estado_liberar_salgado_led   <= '0'; 
					estado_troco_led             <= '1'; -- led do estado de liberar o troco
					salgado_liberado_cliente_led <= '0';
					moeda_liberada_cliente_led   <= '1'; -- led para sinalizar que o dinheiro foi devolvido para o cliente
					IF (continuar = '1') THEN
						proximo_estado <= estado_inicial;
					ELSE
						proximo_estado <= estado_troco;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
END maquina;
