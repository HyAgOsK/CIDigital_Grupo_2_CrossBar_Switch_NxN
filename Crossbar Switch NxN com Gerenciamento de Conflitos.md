# Crossbar Switch NxN com Gerenciamento de Conflitos

# 1 Introdução

Este projeto apresenta a especificação, implementação em RTL (Register Transfer Level) e verificação funcional de um sistema digital de interconexão reconfigurável do tipo **Crossbar Switch NxN com gerenciamento de conflitos**, desenvolvido em **Verilog** como requisito do Trabalho Orientado I (Módulo I) do Programa CI-Digital.

O sistema proposto permite o roteamento simultâneo e independente de múltiplas portas de entrada para múltiplas portas de saída, com **parametrização do número de portas (N)** e da **largura do dado (W)**. Além da comutação dos dados, a arquitetura incorpora lógica de monitoramento para detectar condições de conflito (colisão) quando duas ou mais saídas habilitadas tentam acessar a mesma entrada no mesmo instante.

A implementação foi organizada de forma **modular e hierárquica**, separando:

- **Plano de controle** (geração de seleção one-hot a partir das rotas),
- **Plano de dados (datapath)** (comutação de dados),
- **Plano de monitoramento** (detecção de colisão).

O foco do trabalho está na **correta modelagem RTL**, na **clareza arquitetural** e na **verificação funcional**, sem abordar síntese física, otimização de área, temporização de back-end ou implementação em tecnologia específica.

# 2 Objetivo

O objetivo do projeto é desenvolver e validar um **Crossbar Switch NxN parametrizável** em Verilog, capaz de:

- Conectar qualquer entrada a qualquer saída;
- Permitir múltiplas rotas simultâneas no mesmo ciclo;
- Detectar colisões entre seleções concorrentes;
- Forçar saídas desabilitadas para zero;
- Ser reconfigurável para diferentes valores de **N** e **W** sem reescrita da lógica interna.

Além da implementação funcional, o projeto busca consolidar um fluxo de engenharia digital composto por:

```verilog
**| análise | → | especificação | → | design RTL | → | verificação funcional | → | documentação técnica |**
```

# 3 Análise de Projeto

## 3.1 Objetivo da Análise de Projeto

A análise de projeto tem como finalidade estabelecer uma base técnica clara para a concepção, implementação e verificação do sistema, garantindo coerência entre:

- os requisitos do tema proposto,
- a arquitetura adotada,
- a implementação RTL,
- e os testes realizados.

Essa etapa reduz ambiguidades, organiza decisões arquiteturais e fornece rastreabilidade entre especificação e comportamento observado na simulação.

## 3.2 Objetivos específicos da análise de projeto

- Formalizar os requisitos funcionais e estruturais do crossbar;
- Definir interfaces e sinais de controle;
- Estabelecer a arquitetura modular do sistema;
- Delimitar escopo;
- Definir critérios de verificação e aceitação;
- Garantir consistência entre diagrama, RTL e testbench.

## 3.3 Descrição Geral do Sistema

O sistema consiste em uma **interconexão digital reconfigurável NxN** capaz de rotear dados entre múltiplas portas de entrada e saída por meio de **seleção independente por saída**.

A arquitetura foi organizada em três planos:

1. **Plano de Controle**
    
    Converte os índices de rota `route[j]` em sinais de seleção `select_SE[j][i]` (one-hot por saída), por meio de um módulo denominado `barrel_shifter` (na implementação atual, usado como gerador combinacional de mapa de seleção).
    
2. **Plano de Dados (Datapath)**
    
    Realiza a comutação de `in_data` para `out_data` com base no mapa `select_SE`, e aplica a lógica de `output_enable` (saída desabilitada é forçada a zero).
    
3. **Plano de Monitoramento**
    
    Detecta colisões quando duas ou mais saídas habilitadas selecionam a mesma entrada simultaneamente, gerando a flag global `collision_error`.
    

O sistema é **puramente combinacional no RTL principal**. O clock existente no testbench é utilizado apenas para organização da amostragem dos testes.

## 3.4 Escopo do Projeto

Este projeto contempla:

- Implementação de um crossbar digital parametrizável NxN;
- Suporte a conectividade completa (qualquer entrada → qualquer saída);
- Seleção independente por saída;
- Roteamento simultâneo de múltiplas rotas;
- Geração de mapa de seleção (`select_SE`) no plano de controle;
- Detecção de colisão com flag global `collision_error`;
- Controle individual por saída (`output_enable`);
- Forçamento para zero em saídas desabilitadas;
- Testbench funcional para validação do sistema em **N=8, W>=8**.

## 3.5 Requisitos Funcionais

O sistema deve:

1. Permitir a conexão de qualquer entrada a qualquer saída;
2. Suportar múltiplas rotas distintas simultâneas;
3. Permitir seleção independente por cada saída;
4. Detectar colisão quando duas ou mais saídas habilitadas selecionarem a mesma entrada;
5. Sinalizar a colisão por meio de `collision_error`;
6. Possuir habilitação individual por saída (`output_enable[j]`);
7. Forçar `out_data[j] = 0` quando `output_enable[j] = 0`.

## 3.6 Arquitetura

A arquitetura implementada é composta pelos seguintes blocos: (**Excalidraw**: [https://excalidraw.com/#json=6uOeknHxXXK503_TV-6tO,4uRVQPezpFK6KCy5h4mJFQ](https://excalidraw.com/#json=6uOeknHxXXK503_TV-6tO,4uRVQPezpFK6KCy5h4mJFQ))

![image.png](image.png)

---

## 3.7.2. Plano de Controle (`barrel_shifter`)

O módulo `barrel_shifter` recebe `route_flat` (índices de rota por saída) e gera `select_SE_flat`, uma matriz flatten NxN em que cada linha representa uma saída e cada bit ativo indica qual entrada foi selecionada.

### Função implementada no código

- Extrai `route[j]` de `route_flat`;
- Converte `route[j]` em **one-hot** (`select_SE[j][i]`);
- Se `route[j]` for inválida (`route[j] >= N`), a linha é zerada.

> Na implementação atual, o módulo atua como **gerador combinacional do mapa de seleção** (plano de controle), e não como bloco de deslocamento de dados diretamente.
> 
- Módulo `barrel_shifter`
    - [x]  @Bruno Nassar
    - [x]  @Hyago Vieira

Tarefas:

- [x]  Preciso de um Testbench feito para próxima reunião (26/02)

Responsáveis:

- [x]  @Lucas Souza
- [x]  @Bruno Nassar
- [x]  @Matheus Brandani
- [x]  @Ronan

Analisem o código e me retornem modificações caso necessária, informem para mim melhorias se for necessário, comentem e adicionem em seguida desta página o testebench, juntamente com a modificação caso necessária. Vou colocar um exemplo de testebench.

---

### 3.7.3 Plano de controle (`tb_barrel_shifter`)

Serve para validar o funcionamento do deslocador de bits (barrel shifter), verificando se ele lida corretamente com diferentes padrões de entrada e se a saída está conforme o esperado.

@Lucas Souza → Feito um modelo de testbench simples que verifica a implementação do módulo barrel shifter, os valores de saída em hexadecimal devem ser: 1111 , 8421 , 1248 , 8214

@Bruno Nassar → O testbench final, verifica além dos casos padrões de rotação, usando decimal nos testes, ele demonstra o caso inválido, porém que justamente a matriz de one-hot causa, pela decodificação após o barrel shift.

- Testbench v0 usando N=4
    
    ```verilog
    // descreva aqui o Testbench simples para validar...
    `timescale 1ns/1ps
    
    module tb_barrel_shifter;
    
      parameter N = 4;
      parameter ROUTE_BITS = $clog2(N);
    
      reg  [N*ROUTE_BITS-1:0] route_flat;
      wire [N*N-1:0]          select_SE_flat;
    
      // Instancia DUT
      barrel_shifter #(
        .N(N),
        .ROUTE_BITS(ROUTE_BITS)
      ) dut (
        .route_flat(route_flat),
        .select_SE_flat(select_SE_flat)
      );
    
      initial begin
    
        // -------------------------------
        // CASO 1: Todas saídas -> entrada 0
        // route = {0,0,0,0}
        // -------------------------------
        route_flat = 8'b00000000;
        #10;
    
        // -------------------------------
        // CASO 2: Identidade
        // route[0]=0
        // route[1]=1
        // route[2]=2
        // route[3]=3
        // -------------------------------
        route_flat = {2'b11, 2'b10, 2'b01, 2'b00};
        #10;
    
        // -------------------------------
        // CASO 3: Invertido
        // route[0]=3
        // route[1]=2
        // route[2]=1
        // route[3]=0
        // -------------------------------
        route_flat = {2'b00, 2'b01, 2'b10, 2'b11};
        #10;
    
        // -------------------------------
        // CASO 4: Rota inválida
        // route[3]=4 (100 binário)
        // como ROUTE_BITS=2, 4 vira 00 (overflow)
        // então vamos simular inválido manualmente
        // -------------------------------
        route_flat = {2'b11, 2'b01, 2'b00, 2'b10};
        #10;
    
        $finish;
      end
    
    endmodule
    ```
    
    ![image.png](image%201.png)
    
- Testbench v2 usando N=8
    
    ```verilog
    `timescale 1ns / 1ps
    
    module barrel_shifter_tb();
    
    	parameter N = 8;
    	parameter ROUTE_BITS = $clog2(N);
    
    	reg [N*ROUTE_BITS-1:0] route_flat;
    	wire [N*N-1:0] select_SE_flat;
    
    	barrel_shifter #(
    		.N(N),
    		.ROUTE_BITS(ROUTE_BITS)
    	) DUT (
    		.route_flat(route_flat),
    		.select_SE_flat(select_SE_flat)
    	);
    
    	initial begin
    		$monitor("Rotas: %b_%b_%b_%b_%b_%b_%b_%b | Matriz One-Hot: %b_%b_%b_%b_%b_%b_%b_%b",
    			route_flat[23:21], route_flat[20:18], route_flat[17:15], route_flat[14:12], route_flat[11:9], route_flat[8:6], route_flat[5:3], route_flat[2:0],
    			select_SE_flat[63:56], select_SE_flat[55:48], select_SE_flat[47:40], select_SE_flat[39:32], select_SE_flat[31:24], select_SE_flat[23:16], select_SE_flat[15:8], select_SE_flat[7:0]);
    
    		// Vetor de rotas: {rota8, rota7, rota6, rota5, rota4, rota3, rota2, rota1, rota0}
    		// {7, 6, 5, 4, 3, 2, 1, 0}
    		$display("ROTA VALIDA: {7, 6, 5, 4, 3, 2, 1, 0}");
    		route_flat = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
    		#10;
    
    		// {5, 4, 3, 2, 1, 0, 7, 6}
    		$display("\nROTA VALIDA: {5, 4, 3, 2, 1, 0, 7, 6}");
    		route_flat = {3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0, 3'd7, 3'd6};
    		#10;
    
    		// {5, 4, 3, 2, 1, 0, 6, 7} (Rota inválida)
    		$display("\nROTA INVALIDA: {5, 4, 3, 2, 1, 0, 6, 7}");
    		route_flat = {3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0, 3'd6, 3'd7};
    		#10;
    
    		// Importante:
    		// Por definição, um CROSSBAR SWITCH BARREL SHIFTER suporta apenas N combinações de mapeamentos.
    		//    Enquanto que um CROSSBAR SWITCH TRADICIONAL suporta todas as N! combinações de mapeamentos.
    		// https://en.wikipedia.org/wiki/Barrel_shifter
    	end
    
    endmodule
    
    ```
    
    ![image.png](image%202.png)
    
- Testbench v3 usando N=8
    
    ```verilog
    // test`timescale 1ns / 1ps
    
    module barrel_shifter_tb();
    
    	parameter N = 8;
    	localparam ROUTE_BITS = $clog2(N);
    
    	reg [N*ROUTE_BITS-1:0] route_flat;
    	wire [N*N-1:0] select_SE_flat;
    
    	barrel_shifter #(.N(N)) DUT (
    		.route_flat(route_flat),
    		.select_SE_flat(select_SE_flat)
    	);
    
    	initial begin
    		$monitor("Rotas: %b_%b_%b_%b_%b_%b_%b_%b, Shift: %b | Matriz One-Hot: %b_%b_%b_%b_%b_%b_%b_%b",
    			route_flat[23:21], route_flat[20:18], route_flat[17:15], route_flat[14:12], route_flat[11:9], route_flat[8:6], route_flat[5:3], route_flat[2:0],
    			DUT.shift,
    			select_SE_flat[63:56], select_SE_flat[55:48], select_SE_flat[47:40], select_SE_flat[39:32], select_SE_flat[31:24], select_SE_flat[23:16], select_SE_flat[15:8], select_SE_flat[7:0]);
    
    		// Vetor de rotas: {rota7, rota6, rota5, rota4, rota3, rota2, rota1, rota0}
    		// {7, 6, 5, 4, 3, 2, 1, 0}
    		$display("ROTA VALIDA: {7, 6, 5, 4, 3, 2, 1, 0}");
    		route_flat = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
    		#10;
    
    		// {1, 0, 7, 6, 5, 4, 3, 2}
    		$display("\nROTA VALIDA: {1, 0, 7, 6, 5, 4, 3, 2}");
    		route_flat = {3'd1, 3'd0, 3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2};
    		#10;
    
    		// {0, 1, 7, 6, 5, 4, 3, 2} (Rota inválida)
    		$display("\nROTA INVALIDA: {0, 1, 7, 6, 5, 4, 3, 2}");
    		route_flat = {3'd0, 3'd1, 3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2};
    		#10;
    
    		// Importante:
    		// Por definição, um CROSSBAR SWITCH BARREL SHIFTER suporta apenas N combinações de mapeamentos.
    		//    Enquanto que um CROSSBAR SWITCH TRADICIONAL suporta todas as N! combinações de mapeamentos.
    		// https://en.wikipedia.org/wiki/Barrel_shifter
    	end
    
    endmodule
    ```
    

```verilog
module barrel_shifter #(
  parameter N = 8,
  parameter ROUTE_BITS = $clog2(N)
)(
  input  [N*ROUTE_BITS-1:0] route_flat,      // Vetor flatten com route[j] para cada saída j
  output [N*N-1:0]          select_SE_flat   // Matriz flatten de seleção: linha j ocupa [j*N +: N]
);

  // vetor one hot entrada 0 selecionada
  localparam [N-1:0] BASE_ONEHOT = {{(N-1){1'b0}}, 1'b1};

  // j percorre as saídas (cada saída possui uma rota independente)
  genvar j;
  generate
    for (j = 0; j < N; j = j + 1) begin : GEN_ROW
      // route_j = índice da entrada selecionada pela saída j
      wire [ROUTE_BITS-1:0] route_j;
      // onehot_j = vetor one-hot de tamanho N:
      // bit i = 1 indica que a entrada i deve conectar à saída j
      wire [N-1:0] onehot_j;

      // Vetores para rotação barrel (circular)
      wire [2*N-1:0] base_dup_j;
      wire [2*N-1:0] shifted_j;

      // Extrai route[j] do vetor flatten
      assign route_j = route_flat[j*ROUTE_BITS +: ROUTE_BITS];

      // Duplica o vetor base para permitir rotação circular via shift
      assign base_dup_j = {BASE_ONEHOT, BASE_ONEHOT};

      // Realiza a rotação circular do vetor base
      assign shifted_j = base_dup_j << route_j;

      // Se route_j for válido (<N), pega os N bits menos significativos
      // isso equivale a um left rotate,
      // Se invalido (quando N não é potência de 2) zera linha
      assign onehot_j = (route_j < N) ? shifted_j[N-1:0]:{N{1'b0}};

      // Escreve a linha j da matriz de seleção (select_SE[j][*]) no vetor flatten
      assign select_SE_flat[j*N +: N] = onehot_j;
    end
  endgenerate

endmodule

```

---

```verilog
// BARREL SHIFTER V2: DESLOCAMENTO À ESQUERDA

module barrel_shifter #( //
    parameter N = 8,
    localparam ROUTE_BITS = $clog2(N)
)(
    input  [N*ROUTE_BITS-1:0] route_flat,      // Matriz achatada com o route[ROUTE_BITS] para cada saída j
    output [N*N-1:0]          select_SE_flat   // Matriz achatada com o onehot[N] para cada saída j
);

    // 1) ROTA BASE (portas de entrada em sua ordem natural {..., 3, 2, 1, 0} )
    wire [N*ROUTE_BITS-1:0] base_route_flat;

    genvar j;
    generate
        for (j = 0; j < N; j = j + 1) begin : GEN_BASE_ROUTE
	        assign base_route_flat[j*ROUTE_BITS +: ROUTE_BITS] = j[ROUTE_BITS-1:0];
	    end
    endgenerate

    // 2) DESLOCAMENTO CIRCULAR DA ROTA BASE (BARREL SHIFTER)
    wire [ROUTE_BITS-1:0] shift;

	// Deslocamento circular para a esquerda:
	// * base_route[0] e route[0] são as referências para calcular SHIFT:
	//   -> Se route[0] = 0, então: SHIFT = 0-0 = 0;
	//   -> Se route[0] = 2, então: SHIFT = 2-0 = 2.
    assign shift = route_flat[0 +: ROUTE_BITS] - base_route_flat[0 +: ROUTE_BITS];

	wire [2*N*ROUTE_BITS-1:0] base_route_flat_double;
    assign base_route_flat_double = {base_route_flat, base_route_flat};

    wire [N*ROUTE_BITS-1:0] shifted_route_flat;  // Rota base deslocada circularmente

    generate
        for (j = 0; j < N; j = j + 1) begin : GEN_SHIFTER
	        assign shifted_route_flat[j*ROUTE_BITS +: ROUTE_BITS] =
				   base_route_flat_double[(j + shift)*ROUTE_BITS +: ROUTE_BITS];
	    end
    endgenerate

    // GERAÇÃO DA MATRIZ DE ONE-HOTS
    generate
		for (j = 0; j < N; j = j + 1) begin : GEN_ONEHOT
			// Para o base_route_out[ROUTE_BITS] da saída j, criar o one-hot correspondente
            assign select_SE_flat[j*N +: N] =
			       { {(N-1){1'b0}} , 1'b1 } << shifted_route_flat[j*ROUTE_BITS +: ROUTE_BITS];
        end
    endgenerate

endmodule
```

> **Observação**: Analisando nosso módulo e nosso teste, resumidamente, é feito inicialmente o barrel shifter, e após isso é usado o shift feito, (binarizado-one hot), para se repassado para o crossbar.
> 

---

### 3.7.4 Plano de Dados (`crossbar_nxn`)

O módulo `crossbar_nxn` realiza a comutação de dados utilizando:

- `in_data_flat`
- `select_SE_flat`
- `output_enable`

Para cada saída `j`:

- Se `output_enable[j] = 1`, o módulo seleciona a entrada correspondente ao `select_SE[j][i]`;
- Se `output_enable[j] = 0`, a saída `out_data[j]` é forçada a zero.

A implementação é combinacional e utiliza laços `for` para percorrer saídas (`j`) e entradas (`i`).

Tarefas:

- [x]  Preciso de um Testbench feito para próxima reunião (26/02)

Responsáveis:

- @Fernando
- @Bruno Nassar
- @Bruno
- @jonesnambundo@hotmail.com
- ~~@Érica Silva~~
- @Ronan
- @Luiz Fernando ribeiro
- @Carlos Miguel
- @Matheus Brandani

Analisem o código e me retornem modificações caso necessária, informem para mim melhorias se for necessário, comentem e adicionem em seguida desta página o testebench, juntamente com a modificação caso necessária. Vou colocar um exemplo de testebench.

---

### 3.7.5 Plano de Dados (`tb_crossbar_nxn`)

- @Bruno
    
    ### Plano de controle (tb_crossbar_nxn)
    
    Serve para validar o funcionamento do **Crossbar NxN**, verificando se o roteamento entre entradas e saídas ocorre corretamente conforme:
    
    - dados de entrada
    - matriz de seleção (select)
    - sinal de habilitação das saídas (output_enable)
    
    O testbench aplica diferentes cenários de estímulo ao módulo, permitindo observar o comportamento das saídas no waveform e confirmar visualmente se o roteamento ocorre conforme o esperado.
    
    ---
    
    ### Estrutura do plano de controle
    
    O testbench é dividido em etapas de validação:
    
    1. inicialização do sistema
    2. teste de estado inicial
    3. teste de habilitação das saídas
    4. teste de roteamento one-hot
    5. teste de seleção múltipla (multi-hot)
    6. testes aleatórios para cobertura funcional
    
    Cada etapa verifica um aspecto específico do funcionamento do crossbar
    
    ### Resumo dos testes do testbench (tb_crossbar_nxn)
    
    O testbench foi desenvolvido para verificar o funcionamento do Crossbar NxN aplicando diferentes cenários de entrada, seleção e habilitação das saídas.
    
    Foram realizados testes de:
    
    - inicialização do sistema
    - habilitação e desabilitação das saídas
    - roteamento one-hot (uma entrada por saída)
    - seleção múltipla de entradas (multi-hot)
    - cenários aleatórios
    
    A validação foi feita por meio da análise do waveform, observando se as saídas correspondem corretamente às entradas selecionadas e ao sinal de enable, garantindo o funcionamento adequado do sistema.
    
    ### 1) Teste de Inicialização
    
    **Objetivo:**
    
    Verificar o comportamento do sistema em estado inicial.
    
    Configuração:
    
    - Todas as entradas = 0
    - Matriz de seleção = 0
    - Todas as saídas desabilitadas (output_enable = 0)
    
    Resultado esperado:
    
    - Todas as saídas devem permanecer em 0.
    
    Esse teste garante que o sistema não gere valores indevidos ao iniciar a simulação.
    
    ---
    
    ### 2) Teste de Habilitação das Saídas (Enable = 0)
    
    **Objetivo:**
    
    Validar a prioridade do sinal output_enable.
    
    Configuração:
    
    - Entradas recebem valores aleatórios.
    - Matriz de seleção recebe valores.
    - output_enable = 0 para todas as saídas.
    
    Resultado esperado:
    
    - Todas as saídas devem permanecer em 0, independentemente das entradas ou da seleção.
    
    Esse teste confirma que o enable tem precedência sobre o roteamento.
    
    ---
    
    ### 3) Teste de Roteamento One-Hot
    
    **Objetivo:**
    
    Validar o roteamento básico entre entradas e saídas.
    
    Configuração:
    
    - Cada saída seleciona exatamente uma entrada (seleção one-hot).
    - Todas as saídas habilitadas (output_enable = 1).
    
    Exemplo conceitual:
    
    - out0 seleciona in0
    - out1 seleciona in1
    - out2 seleciona in2
    - ...
    
    Resultado esperado:
    
    - Cada saída deve reproduzir exatamente o valor da entrada selecionada.
    
    Esse teste valida:
    
    - funcionamento correto da indexação
    - correspondência entre matriz de seleção e dados roteados
    - independência entre as saídas
    
    ---
    
    ### 4) Teste de Seleção Múltipla (Multi-Hot)
    
    **Objetivo:**
    
    Verificar o comportamento quando uma saída seleciona mais de uma entrada simultaneamente.
    
    Configuração:
    
    - Uma saída recebe dois bits ativos na sua linha de seleção.
    - Saídas habilitadas.
    
    Resultado esperado:
    
    - A saída deve apresentar o valor resultante da operação OR entre as entradas selecionadas.
    
    Esse teste confirma que o módulo lida corretamente com múltiplas seleções.
    
    ---
    
    ### 5) Teste com Saída Habilitada sem Seleção
    
    **Objetivo:**
    
    Verificar o comportamento quando uma saída está habilitada, mas nenhuma entrada é selecionada.
    
    Configuração:
    
    - output_enable = 1
    - Linha correspondente da matriz de seleção = 0
    
    Resultado esperado:
    
    - A saída deve permanecer em 0.
    
    Esse teste valida que o roteamento depende da seleção ativa.
    
    ---
    
    ### 6) Testes Aleatórios
    
    **Objetivo:**
    
    Exercitar o sistema em múltiplos cenários diferentes.
    
    Configuração:
    
    - Entradas geradas aleatoriamente.
    - Matriz de seleção aleatória.
    - output_enable aleatório.
    
    Resultado esperado:
    
    - As saídas devem refletir corretamente o comportamento esperado do crossbar conforme observado no waveform.
    
    Esse teste aumenta a cobertura funcional e permite verificar a robustez do sistema
    
    ```verilog
    `timescale 1ns/1ps
    
    module tb_crossbar_sem_checker;
    
    parameter N = 8;
    parameter W = 8;
    
    reg  [N*W-1:0] in_data_flat;
    reg  [N*N-1:0] select_SE_flat;
    reg  [N-1:0]   output_enable;
    wire [N*W-1:0] out_data_flat;
    
    // =========================
    // DUT
    // =========================
    crossbar_nxn #(.N(N), .W(W)) dut (
    .in_data_flat(in_data_flat),
    .select_SE_flat(select_SE_flat),
    .output_enable(output_enable),
    .out_data_flat(out_data_flat)
    );
    
    // SINAIS AUXILIARES (8 em 8) -> para ver separado no waveform entradas, saida e seleçã
    
    // Entradas separadas
    wire [W-1:0] in0 = in_data_flat[0*W +: W];
    wire [W-1:0] in1 = in_data_flat[1*W +: W];
    wire [W-1:0] in2 = in_data_flat[2*W +: W];
    wire [W-1:0] in3 = in_data_flat[3*W +: W];
    wire [W-1:0] in4 = in_data_flat[4*W +: W];
    wire [W-1:0] in5 = in_data_flat[5*W +: W];
    wire [W-1:0] in6 = in_data_flat[6*W +: W];
    wire [W-1:0] in7 = in_data_flat[7*W +: W];
    
    // Saídas separadas
    wire [W-1:0] out0 = out_data_flat[0*W +: W];
    wire [W-1:0] out1 = out_data_flat[1*W +: W];
    wire [W-1:0] out2 = out_data_flat[2*W +: W];
    wire [W-1:0] out3 = out_data_flat[3*W +: W];
    wire [W-1:0] out4 = out_data_flat[4*W +: W];
    wire [W-1:0] out5 = out_data_flat[5*W +: W];
    wire [W-1:0] out6 = out_data_flat[6*W +: W];
    wire [W-1:0] out7 = out_data_flat[7*W +: W];
    
    // Seleção separada por saída (cada linha tem N bits)
    wire [N-1:0] sel0 = select_SE_flat[0*N +: N];
    wire [N-1:0] sel1 = select_SE_flat[1*N +: N];
    wire [N-1:0] sel2 = select_SE_flat[2*N +: N];
    wire [N-1:0] sel3 = select_SE_flat[3*N +: N];
    wire [N-1:0] sel4 = select_SE_flat[4*N +: N];
    wire [N-1:0] sel5 = select_SE_flat[5*N +: N];
    wire [N-1:0] sel6 = select_SE_flat[6*N +: N];
    wire [N-1:0] sel7 = select_SE_flat[7*N +: N];
    
    //  geram estímulos)
    
    task rand_inputs;
    integer i;
    begin
    for (i = 0; i < N; i = i + 1)
    in_data_flat[i*W +: W] = $random;
    end
    endtask
    
    task set_onehot_all;
    integer j;
    reg [N-1:0] row;
    begin
    for (j = 0; j < N; j = j + 1) begin
    row = {N{1'b0}};
    row[j % N] = 1'b1;              // outj escolhe inj
    select_SE_flat[j*N +: N] = row;
    end
    end
    endtask
    
    // Sequência de testes)
    
    integer t;
    
    initial begin
    // Inicialização (evita X, (valor indefinido))
    
    t              = 0;
    in_data_flat   = {N*W{1'b0}};
    select_SE_flat = {N*N{1'b0}};
    output_enable  = {N{1'b0}};
    #10;
    
    // 1) Init: tudo zero
    // (mantém)
    
    #10;
    
    // 2) enable=0: mesmo com dados/sel, saídas devem ficar 0 (visual no waveform)
    
    rand_inputs();
    select_SE_flat = $random;
    output_enable  = {N{1'b0}};
    #20;
    
    // 3) One-hot: todas enabled, cada outj pega inj
    
    rand_inputs();
    set_onehot_all();
    output_enable = {N{1'b1}};
    #20;
    
    // 4) Multi-hot / casos especiais
    
    rand_inputs();
    output_enable  = {N{1'b1}};
    select_SE_flat = {N*N{1'b0}};
    
    // out0 = in0 OR in1
    
    select_SE_flat[0*N +: N] = ((1<<0) | (1<<1));
    
    // out1 sem seleção (fica 0 mesmo habilitada)
    
    select_SE_flat[1*N +: N] = 0;
    
    // out2 seleciona in2 mas disable (fica 0)
    
    select_SE_flat[2*N +: N] = (1<<2);
    output_enable[2] = 1'b0;
    
    #30;
    
    // 5) Random (só para variar cenário no waveform)
    
    for (t = 0; t < 10; t = t + 1) begin
      rand_inputs();
      output_enable  = $random;
      select_SE_flat = $random;
      #10;
    end
    
    $finish;
    
    end
    
    endmodule
    ```
    
- @Érica Silva
    
    <aside>
    ✅
    
    Testebench
    
    ```verilog
    `timescale 1ns/1ps
    
    module tb_crossbar_nxn;
    
    parameter N = 8;
    parameter W = 8;
    
    reg  [N*W-1:0] in_data_flat;
    reg  [N*N-1:0] select_SE_flat;
    reg  [N-1:0]   output_enable;
    wire [N*W-1:0] out_data_flat;
    
    // DUT
    crossbar_nxn #(.N(N), .W(W)) dut (
      .in_data_flat(in_data_flat),
      .select_SE_flat(select_SE_flat),
      .output_enable(output_enable),
      .out_data_flat(out_data_flat)
    );
    
    integer i, j;
    integer error_count;
    
    // ==============================
    // TASK: imprimir estado atual
    // ==============================
    task print_state;
    begin
        $display("--------------------------------------------------");
        $display("TIME = %0t", $time);
    
        $write("IN  : ");
        for (i=0;i<N;i=i+1)
            $write("%02h ", in_data_flat[i*W +: W]);
        $display("");
    
        $write("OUT : ");
        for (i=0;i<N;i=i+1)
            $write("%02h ", out_data_flat[i*W +: W]);
        $display("");
    
        $write("EN  : ");
        for (i=0;i<N;i=i+1)
            $write("%b ", output_enable[i]);
        $display("\n--------------------------------------------------\n");
    end
    endtask
    
    // ==============================
    // TASK: checker automático
    // ==============================
    task check_outputs;
    reg [W-1:0] expected;
    reg [N-1:0] sel_row;
    begin
        error_count = 0;
    
        for (j = 0; j < N; j = j + 1) begin
            expected = 0;
            sel_row = select_SE_flat[j*N +: N];
    
            if (output_enable[j]) begin
                for (i = 0; i < N; i = i + 1)
                    if (sel_row[i])
                        expected = expected | in_data_flat[i*W +: W];
            end
    
            if (out_data_flat[j*W +: W] !== expected) begin
                $display("ERRO: OUT%0d esperado=%02h obtido=%02h",
                         j, expected, out_data_flat[j*W +: W]);
                error_count = error_count + 1;
            end
        end
    
        if (error_count == 0)
            $display("STATUS: PASS \n");
        else
            $display("STATUS: FAIL  (%0d erros)\n", error_count);
    end
    endtask
    
    // ==============================
    // ESTÍMULOS
    // ==============================
    initial begin
    
        in_data_flat   = 0;
        select_SE_flat = 0;
        output_enable  = 0;
        #10;
    
        // TESTE 1 - tudo zero
        $display("TESTE 1 - Inicialização");
        print_state();
        check_outputs();
    
        // TESTE 2 - one hot
        $display("TESTE 2 - One Hot");
        for (i=0;i<N;i=i+1)
            in_data_flat[i*W +: W] = i;
    
        for (j=0;j<N;j=j+1)
            select_SE_flat[j*N +: N] = (1<<j);
    
        output_enable = {N{1'b1}};
        #10;
    
        print_state();
        check_outputs();
    
        // TESTE 3 - multi-hot
        $display("TESTE 3 - Multi Hot");
        select_SE_flat = 0;
        select_SE_flat[0*N +: N] = (1<<0) | (1<<1); // OR
        output_enable = {N{1'b1}};
        #10;
    
        print_state();
        check_outputs();
    
        $finish;
    
    end
    
    endmodule
    ```
    
    </aside>
    
- @Hyago Vieira
    - Testbench:
        
        ```verilog
        `timescale 1ns/1ps
        module tb_crossbar_sem_checker;
        
          parameter N = 8;
          parameter W = 8;
        
          reg  [N*W-1:0] in_data_flat;
          reg  [N*N-1:0] select_SE_flat;
          reg  [N-1:0]   output_enable;
          wire [N*W-1:0] out_data_flat;
        
          // DUT
          crossbar_nxn #(.N(N), .W(W)) dut (
            .in_data_flat(in_data_flat),
            .select_SE_flat(select_SE_flat),
            .output_enable(output_enable),
            .out_data_flat(out_data_flat)
          );
        
          // =========================================================
          // SINAIS PARA WAVE (só o necessário)
          // =========================================================
          wire [W-1:0] in0  = in_data_flat[0*W +: W];
          wire [W-1:0] in1  = in_data_flat[1*W +: W];
          wire [W-1:0] in2  = in_data_flat[2*W +: W];
          wire [W-1:0] in3  = in_data_flat[3*W +: W];
        
          wire [W-1:0] out0 = out_data_flat[0*W +: W];
          wire [W-1:0] out1 = out_data_flat[1*W +: W];
          wire [W-1:0] out2 = out_data_flat[2*W +: W];
          wire [W-1:0] out3 = out_data_flat[3*W +: W];
        
          wire [N-1:0] sel0 = select_SE_flat[0*N +: N];
          wire [N-1:0] sel1 = select_SE_flat[1*N +: N];
          wire [N-1:0] sel2 = select_SE_flat[2*N +: N];
          wire [N-1:0] sel3 = select_SE_flat[3*N +: N];
        
          // =========================================================
          // HELPERS SIMPLES
          // =========================================================
          task set_in_fixed;
            begin
              // valores fáceis de enxergar
              in_data_flat = {N*W{1'b0}};
              in_data_flat[0*W +: W] = 8'hA0;
              in_data_flat[1*W +: W] = 8'hB1;
              in_data_flat[2*W +: W] = 8'hC2;
              in_data_flat[3*W +: W] = 8'hD3;
            end
          endtask
        
          task clear_all;
            begin
              in_data_flat   = {N*W{1'b0}};
              select_SE_flat = {N*N{1'b0}};
              output_enable  = {N{1'b0}};
            end
          endtask
        
          task show_min;
            input [8*32:1] tag;
            begin
              $display("---- %s ----", tag);
              $display("en[3:0]=%b  sel0=%b sel1=%b sel2=%b sel3=%b",
                       output_enable[3:0], sel0, sel1, sel2, sel3);
              $display("in0=%h in1=%h in2=%h in3=%h | out0=%h out1=%h out2=%h out3=%h",
                       in0,in1,in2,in3, out0,out1,out2,out3);
            end
          endtask
        
          initial begin
            // opcional: gera VCD (se usar Icarus/GTKWave)
            // $dumpfile("tb_crossbar_sem_checker.vcd");
            // $dumpvars(0, tb_crossbar_sem_checker);
        
            clear_all();
            #5;
        
            // =====================================================
            // 1) ENABLE=0 => tudo 0 (mesmo com dados e seleção)
            // =====================================================
            set_in_fixed();
            select_SE_flat[0*N +: N] = (1<<0); // out0<-in0 (mas enable=0)
            select_SE_flat[1*N +: N] = (1<<1); // out1<-in1
            select_SE_flat[2*N +: N] = (1<<2); // out2<-in2
            select_SE_flat[3*N +: N] = (1<<3); // out3<-in3
            output_enable = 8'b0000_0000;
            #5;
            show_min("1) enable=0 => saidas zeradas");
            #10;
        
            // =====================================================
            // 2) ONE-HOT (funcionamento normal)
            // out0<-in0, out1<-in1, out2<-in2, out3<-in3
            // =====================================================
            output_enable = 8'b0000_1111;
            #5;
            show_min("2) one-hot normal");
            #10;
        
            // =====================================================
            // 3) DISABLE de uma saída: desliga out2
            // =====================================================
            output_enable[2] = 1'b0;
            #5;
            show_min("3) disable out2 => out2=0");
            #10;
        
            // =====================================================
            // 4) MULTI-HOT em out0 (caso especial)
            // Como o módulo não usa OR, ele pega a ULTIMA entrada ativa no for
            // sel0 = in0 e in1 ativos => out0 tende a virar in1 (índice maior)
            // =====================================================
            output_enable = 8'b0000_1111;
            output_enable[2] = 1'b1; // volta out2
            select_SE_flat[0*N +: N] = ((1<<0) | (1<<1)); // multi-hot
            #5;
            show_min("4) multi-hot em out0 (visualizar comportamento)");
            #10;
        
            $display("FIM");
            $finish;
          end
        
        endmodule
        
        ```
        
    
    ![image.png](image%203.png)
    
    ![image.png](c7cbf83c-f001-4ee9-ac0a-314746104103.png)
    

```verilog
module crossbar_nxn #(
  parameter N = 8,
  parameter W = 8
)(
  input  [N*W-1:0]     in_data_flat,     // Entradas flatten: in_data[i] ocupa [i*W +: W]
  input  [N*N-1:0]     select_SE_flat,   // Matriz de seleção flatten: linha j em [j*N +: N]
  input  [N-1:0]       output_enable,    // Habilitação por saída
  output reg [N-1:0]   collision_error,  // Erro de colisão de seleção
  output reg [N*W-1:0] out_data_flat     // Saídas flatten: out_data[j] ocupa [j*W +: W]
);

  integer i, j;

  // tmp_out acumula o dado selecionado para a saída j
  reg [W-1:0] tmp_out;

  // sel_row representa a linha j da matriz de seleção (one-hot idealmente)
  reg [N-1:0] sel_row;

  always @* begin
    // Inicializa todas as saídas com zero
    // Isso ajuda a garantir comportamento determinístico e simplifica lógica combinacional.
    out_data_flat = {N*W{1'b0}};

    // Para cada saída j...
    for (j = 0; j < N; j = j + 1) begin
      tmp_out = {W{1'b0}};
      sel_row = select_SE_flat[j*N +: N]; // select_SE[j][*]

      // Só comuta dados se a saída estiver habilitada
      if (output_enable[j]) begin
        // Percorre todas as entradas i
        for (i = 0; i < N; i = i + 1) begin
          // Se bit i da linha de seleção estiver ativo, encaminha in_data[i] para saída j
          // Uso de OR torna o módulo robusto caso haja multi-hot acidental em sel_row
          // (em condição ideal, sel_row é one-hot e apenas uma entrada contribui).
          if (sel_row[i])
            tmp_out = in_data_flat[i*W +: W]; // ultima entrada contribui, caso tenha mais de uma a ultima seleção de rota entra
        end
      end

      // Escreve a saída j no vetor flatten
      // Se output_enable[j]=0, permanece zero (precedência de disable)
      out_data_flat[j*W +: W] = tmp_out;
    end
  end

endmodule

```

---

---

### 3.7.6 Plano de Monitoramento (`collision_monitor`)

O módulo `collision_monitor` monitora `route_flat` e `output_enable` para detectar conflitos.

A lógica compara pares de saídas habilitadas (`a`, `b`) e ativa `collision_error` quando:

- `output_enable[a] == 1`
- `output_enable[b] == 1`
- `route[a] == route[b]`

Trata-se de uma lógica combinacional de comparação com complexidade O(N²), adequada ao escopo do projeto acadêmico.

- Módulo
    - [x]  @Hyago Vieira
    - [x]  @Bruno Nassar

Tarefas:

- [x]  Preciso de um Testbench feito para próxima reunião (26/02)

Responsáveis:

- [x]  @Hyago Vieira
- [x]  @Fernando
- [x]  @Carlos Miguel

Analisem o código e me retornem modificações caso necessária, informem para mim melhorias se for necessário, comentem e adicionem em seguida desta página o testebench, juntamente com a modificação caso necessária. Vou colocar um exemplo de testebench.

---

### 3.7.8 Plano de Monitoramento (`tb_colission_monitor`)

@Hyago Vieira → É um testbench combinacional e direto, que valida se o `colision_monitor` :

- detecta colisão quando há rotas repitidas entre saídas habilitadas
- ignora rotas repetidas quando alguma das saídas está desabilitada

@Bruno Nassar → Testbench ampliada para N=8. Exibição de resultados de colisão formatados no terminal. 

- Testbench v0 usando N=4
    
    ```verilog
    // Desenvolva o testbench aqui...
    // Testbench simples para validar collision_monitor
    `timescale 1ns/1ps
    
    module tb_collision_monitor;
    
      parameter N = 4;
      parameter ROUTE_BITS = $clog2(N);
    
      reg  [N*ROUTE_BITS-1:0] route_flat;
      reg  [N-1:0]            output_enable;
      wire                    collision_error;
    
      // Instancia DUT
      collision_monitor #(
        .N(N),
        .ROUTE_BITS(ROUTE_BITS)
      ) dut (
        .route_flat(route_flat),
        .output_enable(output_enable),
        .collision_error(collision_error)
      );
    
      initial begin
        $display("==== INICIO TESTE collision_monitor ====");
        $monitor("t=%0t | output_enable=%b | route_flat=%b | collision_error=%b",
                 $time, output_enable, route_flat, collision_error);
    
        // ------------------------------------------
        // CASO 1: Todas saídas desabilitadas
        // Mesmo com rotas iguais, NÃO deve dar colisão
        // ------------------------------------------
        route_flat     = {2'b00, 2'b00, 2'b00, 2'b00};
        output_enable  = 4'b0000;
        #10;
    
        // ------------------------------------------
        // CASO 2: Todas habilitadas, rotas diferentes (identidade)
        // route[0]=0, route[1]=1, route[2]=2, route[3]=3
        // NÃO deve dar colisão
        // ------------------------------------------
        route_flat     = {2'b11, 2'b10, 2'b01, 2'b00};
        output_enable  = 4'b1111;
        #10;
    
        // ------------------------------------------
        // CASO 3: Colisão entre duas saídas habilitadas
        // route[0]=1 e route[1]=1 -> colisão
        // ------------------------------------------
        route_flat     = {2'b11, 2'b10, 2'b01, 2'b01};
        output_enable  = 4'b1111;
        #10;
    
        // ------------------------------------------
        // CASO 4: Rotas iguais, mas uma saída desabilitada
        // route[0]=2 e route[1]=2, porém output_enable[1]=0
        // NÃO deve dar colisão
        // ------------------------------------------
        route_flat     = {2'b00, 2'b01, 2'b10, 2'b10};
        output_enable  = 4'b1101; // saída 1 desabilitada
        #10;
    
        // ------------------------------------------
        // CASO 5: Múltiplas colisões
        // route[0]=3, route[1]=3 e route[2]=0, route[3]=0
        // Deve dar colisão
        // ------------------------------------------
        route_flat     = {2'b00, 2'b00, 2'b11, 2'b11};
        output_enable  = 4'b1111;
        #10;
    
        $display("==== FIM TESTE collision_monitor ====");
        $finish;
      end
    
    endmodule
    ```
    
    ![image.png](image%204.png)
    
    ![image.png](image%205.png)
    
- Testbench v1 usando N=8
    
    ```verilog
    `timescale 1ns/1ps
    
    module tb_collision_monitor;
    
      parameter N = 8;
      parameter ROUTE_BITS = $clog2(N);
    
      reg  [N*ROUTE_BITS-1:0] route_flat;
      reg  [N-1:0]            output_enable;
      wire                    collision_error;
    
      // Instancia DUT
      collision_monitor #(
        .N(N),
        .ROUTE_BITS(ROUTE_BITS)
      ) dut (
        .route_flat(route_flat),
        .output_enable(output_enable),
        .collision_error(collision_error)
      );
    
      initial begin
        $display("==== INICIO TESTE collision_monitor ====");
        $monitor("output_enable=%b_%b | route_flat=%b_%b_%b_%b_%b_%b_%b_%b | collision_error=%b",
                 output_enable[7:4], output_enable[3:0],
    			 route_flat[23:21], route_flat[20:18], route_flat[17:15], route_flat[14:12], route_flat[11:9], route_flat[8:6], route_flat[5:3], route_flat[2:0],
    			 collision_error);
    
        // ------------------------------------------
        // CASO 1: Todas saídas desabilitadas
        // Mesmo com rotas iguais, NÃO deve dar colisão
        // ------------------------------------------
        route_flat     = {3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd0};
        output_enable  = 8'd0;
        #10;
    
        // ------------------------------------------
        // CASO 2: Todas habilitadas, rotas diferentes (identidade)
        // route[0]=0, route[1]=1, route[2]=2, route[3]=3, ...
        // NÃO deve dar colisão
        // ------------------------------------------
    	route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
        output_enable  = 8'b1111_1111;
        #10;
    
        // ------------------------------------------
        // CASO 3: Colisão entre duas saídas habilitadas
        // route[0]=1 e route[1]=1 -> colisão
        // ------------------------------------------
    	route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd1};
        output_enable  = 8'b1111_1111;
        #10;
    
        // ------------------------------------------
        // CASO 4: Rotas iguais, mas uma saída desabilitada
        // route[0]=1 e route[1]=1, porém output_enable[1]=0
        // NÃO deve dar colisão
        // ------------------------------------------
        route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd1};
        output_enable  = 8'b1111_1101; // saída 1 desabilitada
        #10;
    
        // ------------------------------------------
        // CASO 5: Múltiplas colisões
        // route[0]=3, route[1]=3 e route[2]=0, route[3]=0
        // Deve dar colisão
        // ------------------------------------------
        route_flat     = {2'b00, 2'b00, 2'b11, 2'b11};
    	route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd0, 3'd0, 3'd3, 3'd3};
        output_enable  = 8'b1111_1111;
        #10;
    
        $display("==== FIM TESTE collision_monitor ====");
        $finish;
      end
    
    endmodule
    ```
    
    ![image.png](image%206.png)
    
    ![image.png](image%207.png)
    

```verilog
module collision_monitor #(
  parameter N = 8,
  parameter ROUTE_BITS = $clog2(N)
)(
  input  [N*ROUTE_BITS-1:0] route_flat,   // Rotas de todas as saídas (flatten)
  input  [N-1:0] output_enable,// Máscara de habilitação por saída
  output reg collision_error // Flag global de colisão
);

  // Índices de comparação entre pares de saídas
  integer a, b;

  // Registradores temporários para armazenar route[a] e route[b]
  reg [ROUTE_BITS-1:0] route_a, route_b;

  always @* begin
    // Valor padrão: sem colisão
    collision_error = 1'b0;

    // Compara todos os pares únicos de saídas (a,b) com b>a
    // Complexidade O(N^2),  pequeno/moderado neste projetoaceitável para N.
    for (a = 0; a < N; a = a + 1) begin
      for (b = a + 1; b < N; b = b + 1) begin
        // Extrai as rotas atuais de a e b
        route_a = route_flat[a*ROUTE_BITS +: ROUTE_BITS];
        route_b = route_flat[b*ROUTE_BITS +: ROUTE_BITS];

        // Há colisão se:
        // 1) as duas saídas estão habilitadas
        // 2) ambas selecionam a mesma entrada
        if (output_enable[a] && output_enable[b] && (route_a == route_b))
          collision_error = 1'b1;
      end
    end
  end

endmodule

```

---

> **Observação**: Analisando nosso módulo e nosso teste, resumidamente, é obtido as rotas e verifica das entradas que selecionam a mesma saída (colisão detectada) caso contrário não.
> 

---

### 3.7.7 System Top Level (`crossbar_top_level`)

O módulo `crossbar_top_level` é o **módulo principal** do sistema.

Ele junta os 3 blocos do projeto:

- `barrel_shifter` → gera a seleção (`select_SE_int_flat`)
- `crossbar_nxn` → faz a comutação dos dados
- `collision_monitor` → detecta colisão de rotas

### Entradas

- **`in_data_flat [N*W-1:0]`**
    
    Dados de entrada (flatten). Contém `N` entradas, cada uma com `W` bits.
    
- **`route_flat [N*ROUTE_BITS-1:0]`**
    
    Rotas por saída (flatten).
    
    Cada `route[j]` diz qual entrada será conectada à saída `j`.
    
- **`output_enable [N-1:0]`**
    
    Habilitação por saída.
    
    Se `output_enable[j] = 0`, a saída `j` é forçada para zero.
    

### Saídas

- **`out_data_flat [N*W-1:0]`**
    
    Dados de saída (flatten), após a comutação.
    
- **`collision_error`**
    
    Flag global de colisão (1 = existe conflito de rota entre saídas habilitadas).
    

Tarefas:

- [x]  Preciso de um Testbench feito para próxima reunião (26/02)

Responsáveis:

- @Hyago Vieira
- @Fernando
- @Érica Silva
- @Matheus Brandani

Analisem o código e me retornem modificações caso necessária, informem para mim melhorias se for necessário, comentem e adicionem em seguida desta página o testebench, juntamente com a modificação caso necessária. Vou colocar um exemplo de testebench.

---

### 3.7.8 System Top Level (`tb_crossbar_nxn`)

- @Matheus Brandani
- @Hyago Vieira

- TestbenchV0 Top-Level:
    
    ```verilog
    `timescale 1ns/1ps
    
    module tb_crossbar_monitor_cases;
    
      parameter N = 8;
      parameter W = 8;
      parameter ROUTE_BITS = $clog2(N);
    
      reg  [N*W-1:0]          in_data_flat;
      reg  [N*ROUTE_BITS-1:0] route_flat;
      reg  [N-1:0]            output_enable;
    
      wire [N*W-1:0]          out_data_flat;
      wire                    collision_error;
    
      crossbar_top_level #(
        .N(N),
        .W(W),
        .ROUTE_BITS(ROUTE_BITS)
      ) dut (
        .in_data_flat(in_data_flat),
        .route_flat(route_flat),
        .output_enable(output_enable),
        .out_data_flat(out_data_flat),
        .collision_error(collision_error)
      );
    
      initial begin
    
        // Input pattern:
        in_data_flat = {
          8'h88, 8'h77, 8'h66, 8'h55,
          8'h44, 8'h33, 8'h22, 8'h11
        };
    
        // Enable all outputs
        output_enable = 8'b1111_1111;
    
        // CASE 1: VALID MAPPING (NO COLLISION)
        route_flat = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd2,3'd1,3'd0};
        #10;
    
        // CASE 2: SIMPLE COLLISION
        route_flat = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd3,3'd1,3'd0};
        #10;
    
        // CASE 3: MULTIPLE COLLISIONS
        route_flat = {3'd7,3'd6,3'd5,3'd5,3'd2,3'd2,3'd1,3'd0};
        #10;
    
        // CASE 4 MASK COLLISION - A COLISÃO EXISTE MAS EU TRAVO A PORTA (MÁSCARA)
        route_flat = {3'd7,3'd6,3'd5,3'd5,3'd3,3'd2,3'd1,3'd0};
        output_enable = 8'b1110_1111;
        #10;
        // CASE 5: COLLISION BUT ONE DISABLED
        route_flat    = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd3,3'd1,3'd0};
        output_enable = 8'b1111_1101;
        #10;
    
        // CASE 6: EXTREME COLLISION
        output_enable = 8'b1111_1111;
        route_flat = {3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0};
        #10;
    
        $stop;
      end
    
    endmodule
    
    ```
    
    ![Captura de tela 2026-02-26 003505.png](Captura_de_tela_2026-02-26_003505.png)
    
    ![image.png](image%208.png)
    

## 3.8 Casos de teste

- [x]  Caso A - 4 rotas simultâneas (sem colisão)
    
    Valida o roteamento paralelo com múltiplas saídas ativas e rotas distintas, comprovando ausência de interferência indevida entre barramentos.
    
- [x]  Caso B - Colisão forçada
    
    Força duas saídas habilitadas a selecionarem a mesma entrada e valida a ativação de `collision_error`.
    
- [x]  Caso C -Habilitação/zero + colisão mascarada

Valida:

- precedência da lógica de `output_enable` (saída desabilitada zerada),
- e cenário em que rotas repetidas não geram colisão quando uma das saídas está desabilitada.
- [x]  Caso D - Mudança dinâmica de rota
    
    Altera a rota de uma saída habilitada ao longo do tempo e observa a comutação correta no DUT.
    

```verilog
module crossbar_top_level #(
  parameter N = 8,
  parameter W = 8,
	parameter ROUTE_BITS = $clog2(N) 
)(
  input  [N*W-1:0]          in_data_flat,     // Dados de entrada (flatten)
  input  [N*ROUTE_BITS-1:0] route_flat,       // Rotas por saída (flatten)
  input  [N-1:0]            output_enable,    // Habilitação por saída
  output [N*W-1:0]          out_data_flat,    // Dados de saída (flatten)
  output                    collision_error    // Flag global de colisão
);

  // Sinal interno: matriz de seleção gerada a partir das rotas
  // Representa select_SE[j][i] em formato flatten.
  wire [N*N-1:0] select_SE_int_flat;

  // ---------------------------------------------------------------------------
  // Plano de Controle: converte route[j] em one-hot select_SE[j][i]
  // ---------------------------------------------------------------------------
  barrel_shifter #(
    .N(N),
    .ROUTE_BITS(ROUTE_BITS)
  ) u_barrel_shifter (
    .route_flat(route_flat),
    .select_SE_flat(select_SE_int_flat)
  );

  // ---------------------------------------------------------------------------
  // Datapath: realiza a comutação NxN + aplica enable/zero por saída
  // ---------------------------------------------------------------------------
  crossbar_nxn #(
    .N(N),
    .W(W)
  ) u_crossbar_nxn (
    .in_data_flat(in_data_flat),
    .select_SE_flat(select_SE_int_flat),
    .output_enable(output_enable),
    .out_data_flat(out_data_flat)
  );

  // ---------------------------------------------------------------------------
  // Monitoramento: detecta conflito de seleção entre saídas habilitadas
  // ---------------------------------------------------------------------------
  collision_monitor #(
    .N(N),
    .ROUTE_BITS(ROUTE_BITS)
  ) u_collision_monitor (
    .route_flat(route_flat),
    .output_enable(output_enable),
    .collision_error(collision_error)
  );

endmodule

```

---

---

## 3.9 Requisitos de Implementação (Design RTL)

A implementação RTL atende aos seguintes critérios:

- Uso de **parâmetros (`parameter`)** para `N`, `W` e `ROUTE_BITS`;
- Uso de **laços `for`** e **`generate`** para escalabilidade;
- Organização modular hierárquica;
- Lógica combinacional para seleção, comutação e monitoramento;
- Validação com instância mínima **N=8** e **W>=8** no testbench.

## 3.10 Requisitos de Verificação

- A verificação deve suportar a configuração sintetizada
- Deve ser verificado o roteamento paralelo de alta densidade, com pelo menos 4 rotas simultâneas distintas no mesmo ciclo de teste.
- Deve ser verificada a detecção de conflito quando múltiplas saídas selecionam a mesma entrada, com ativação do sinal `collision_error`.
- Deve ser avaliado o comportamento do sistema sob mudanças dinâmicas de configuração de rotas, por meio da observação de diagramas de tempo.

### 3.11 IDE, HDL e Simulador

- VScode
    - Integração rápida com GitHub
    - Contém extensões de renderização de Markdown
    - Integra CLI
- Verilog
    - IEEE 1364-2005 and 1364-1995 (Verilog)
    - Mentor ModelSim - Intel FPGA Starter Edition 2020.1 Rev. 2020.02 - feb, 28 2020

### 3.13 Estrutura de repositório

- link: https://github.com/HyAgOsK/CIDigital_Grupo_2_CrossBar_Switch_NxN

```verilog
CIDigital_Grupo_2_CrossBar_Switch_NxN/
├── .gitignore
├── README.md
├── barrel_shifter.v        
├── crossbar_nxn.v          
├── collision_monitor.v      
├── crossbar_system.v       
├── tb_barrel_shifter.v      
├── tb_crossbar_nxn.v       
├── tb_colission_monitor.v
└── tb_crossbar_system.v    
```

# 4 Conclusão

….

Este projeto apresentou o desenvolvimento de um **Crossbar Switch NxN com gerenciamento de conflitos**, implementado em Verilog com arquitetura modular e parametrizável. A solução foi estruturada em três planos, controle, datapath e monitoramento e integrada por um módulo top-level coerente com o diagrama de blocos proposto.

…
A verificação funcional por testbench demonstrou o atendimento aos cenários exigidos pelo tema, incluindo:

- [ ]  roteamento paralelo de múltiplas saídas,
- [ ]  detecção de colisão,
- [ ]  controle de habilitação com saída zerada,
- [ ]  e mudança dinâmica de rotas.

# 5 Referências bibliográficas

- **Tema 2 — Crossbar Switch NxN com Gerenciamento de Conflitos** (enunciado do projeto).
- **SD192 – Trabalho Orientado I** (orientações da disciplina / módulo).
- IEEE Std 1364 — Verilog Hardware Description Language.
- Documentação e código RTL desenvolvidos pelo grupo (módulos e testbench do projeto)

# Anexos

… simulações, testes, prints tudo que podemos adicionar a mais….