# Introdução

%% DOCUMENTO NÃO DEFINITIVO %%

Este documento apresenta escopo do DUT, convenções estabelecidas, modelo de referência, testes mínimos requeridos para verificação com checks lists dos testes realizados ,resultados esperados(*state tables* de referência), proposição de plano de execução com definição de sequências e métodos. 

- É referência para implementação na etapa de **teste e verificação**.

# Test and Verification topology overview (System level)

```text
                 Test and Verification Topology Overview (Testbench)
+--------------------------------------------------------------------------------+
| tb_crossbar_system                                                    	 |
|                                                                                |
|  +---------------------------+        +-----------------------------------+    |
|  |      Test Sequencer       |        |            Scoreboard             |    |
|  |         (mínimos)         |        |        (modelo esperado)          |    |
|  | Testcases                 |        |                                   |    |
|  | - A: 4 rotas              |        |   -Expected_collision             |    |   
|  | - B: colisão forçada      |        |   -Expected_out                   |    |
|  | - C: enable gate test     |        |   -...                            |    |
|  | - D: rota dinâmica        |        |   -...                            |    |
|  | - ...                     |        |                                   |    |
|  +-------------+-------------+        |                                   |    |
|                |                      +------------------+----------------+    |
|                |                                         |                     |
|                v                                         v                     |
|  +---------------------------- -+        +------------------------------+      |
|  | Drivers                      |        |     Checkers / Assertions    |      |
|  |                              |        |                              |      |
|  | drive_in_data_tb[N][W] ------+------->|*compare out_data vs expected |      |
|  | drive_route_tb[N][ROUTE_BITS]+------->|*compare collision_error      |      |
|  | drive_output_enable_tb[N]----+------->|*(opcional) properties SVA    |      |
|  +-------------+----------------+        +------------------------------+      |
|                |                                                               |
|                | (clock/trigger TB para amostragem / sincronizar vetores)      |
|                v                                                               |
|  +------------------------------ DUT -----------------------------+            |
|  |                 crossbar_system #(N=2^k, W)                    |            |
|  |                                                                |            |
|  |  in_data[N][W]        <----- in_data_tb[N][W] -----------------+            |
|  |  route[N][ROUTE_BITS] <----- route_tb[N][ROUTE_BITS]-----------+            |
|  |  output_enable[N]     <----- output_enable_tb[N] --------------+            |
|  |                                                                |            |
|  |                                         out_data[N][W]  --------->(checkers)|
|  |                                         collision_error --------->(checkers)|
|  +----------------------------------------------------------------+            |
+--------------------------------------------------------------------------------+

REF. MODEL: 
Expected_out: expected_out[j] = output_enable_tb[j] ? in_data_tb[route_tb[j]] : 0
Expected_collision: 
	expected_collision = OR_{a<b} 
				(
				output_enable_tb[a] & 
				output_enable_tb[b] & 
				(route_tb[a] == route_tb[b])
	   			)
	   			
```


# TEST: DUT (Crosspoint System) 
## Escopo do **DUT** (`crossbar_system`):
- Entradas:
	- `in_data[0..7]` (8 bits),
	- `route[0..7]` (`ROUTE_BITS = 3` bits),
	- `output_enable[0..7]` (8 bit)
- Saída:
	- `out_data[0..7]` (8 bits),
	- `collision_error` (1 bit)

## Verification Strategy

### Abordagem

- Directed tests para cobrir requisitos mínimos (Listados em A-D).
- Scoreboard (oracle) para comparar `out_data` e `collision_error` com valores esperados.
- (Opcional) Assertions SVA no TB para reforcar contratos (sem depender de sinais internos).

### Convenção de nomenclatura
- Sinais dirigidos pelo testbench usam sufixo `_tb` e são conectados diretamente as portas do DUT:
	- `in_data_tb -> in_data`
	- `route_tb -> route`
	- `output_enable_tb -> output_enable`

### Amostragem determinística

Recomendação (determinismo por amostragem):
- aplicar estímulos (atualizar `*_tb`) em `negedge clk_tb`;
- aguardar estabilização combinacional (delta cycles, se aplicável);
- amostrar e verificar em `posedge clk_tb`.
- 

### Reference Model:
- `out_data[j] = output_enable_tb[j] ? in_data_tb[ route_tb[j] ] : 8'h00`
- `collision_error = OR_{0<=a<b<8} ( output_enable_tb[a] & output_enable_tb[b] & (route_tb[a] == route_tb[b]) )`

### Convenções das state tables:
- Vetores são listados como `[x0,x1,x2,x3,x4,x5,x6,x7]`.
- Data streaming representados em `in_data` e `out_data` são valores hexadecimais `8'h00`.
- `route_tb` decimal (0..7).
- `output_enable_tb` bits (0/1).


## Requisitos Mínimos de Teste 

Implementar sequência de testes a baixo. Executar script de verificação. 
### Caso A — 4 rotas simultâneas 

- Critério: paralelismo, sem concorrência/colisão

 State table estimada

| Ciclo | route_tb[0..7]      | output_enable_tb[0..7] | collision_error | in_data_tb[0..7]            | out_data[0..7] esperado     |
| ----: | ------------------- | ------------------- | --------------: | --------------------------- | --------------------------- |
|    T0 | `[3,6,1,7,2,5,0,4]` | `[1,1,1,1,0,0,0,0]`    |               0 | `[10,21,32,43,54,65,76,87]` | `[43,76,21,87,00,00,00,00]` |

Notas de verificação:
- As saídas habilitadas (0..3) acessam entradas distintas (3,6,1,7), portanto `collision_error` deve permanecer 0.
- A ausência de interferência e verificada porque cada `out_data[j]` bate com a entrada indexada por `route_tb[j]`.

### Caso B — Monitor de Colisão (Concorrência de recurso)

- Critério: Forçar condição para que ocorra collision_error=1

State table estimada

| Ciclo | route_tb[0..7]      | output_enable_tb[0..7] | collision_error | in_data_tb[0..7]            | out_data[0..7] esperado     |
| ----: | ------------------- | ------------------- | --------------: | --------------------------- | --------------------------- |
|    T0 | `[2,6,1,2,0,5,7,4]` | `[1,0,0,1,0,0,0,0]`    |               1 | `[10,21,32,43,54,65,76,87]` | `[32,00,00,32,00,00,00,00]` |
- saídas 0 e 3 estao habilitadas e ambas selecionam `route_tb=2`.
- Requisito exige apenas sinalização(set flag): `collision_error`  1.

### Caso C — Predominância

Objetivo: 
- demonstrar simultaneamente:
	- `output_enable[j]=0` impõe `out_data[j] = 00` independentemente do mapeamento ou conteúdo in_data(data streaming).
	- (No TB: `output_enable_tb[j]=0` impõe `out_data[j] = 00` independentemente do mapeamento ou conteúdo `in_data_tb`.)
	- Uma rota potencialmente conflitante não deve gerar `collision_error` quando uma das saídas envolvidas estiver desabilitada.

| Ciclo | route_tb[0..7]      | output_enable_tb[0..7] | collision_error | in_data_tb[0..7]            | out_data[0..7] esperado     |
| ----: | ------------------- | ------------------- | --------------: | --------------------------- | --------------------------- |
|    T0 | `[5,6,1,7,5,0,2,3]` | `[1,1,1,1,0,0,0,0]` |               0 | `[10,21,32,43,54,65,76,87]` | `[65,76,21,87,00,00,00,00]` |
|    T1 | `[5,6,1,7,7,0,2,3]` | `[1,1,1,1,0,0,0,0]` |               0 | `[A0,B1,C2,D3,E4,F5,16,27]` | `[F5,16,B1,27,00,00,00,00]` |

Observações:
- Em T0, 
	- `route[0]=5` e `route[4]=5`, mas `output_enable[4]=0`. 
	- `route_tb[0]=5` e `route_tb[4]=5`, mas `output_enable_tb[4]=0`.
		- Por definição, não há concorrência:
			- `collision_error=0`.
- Em T1, 
	- `route[4]` muda (5->7) e `in_data` altera completamente. 
	- `route_tb[4]` muda (5->7) e `in_data_tb` altera completamente.
		- `output_enable_tb[4]=0` impõe o estado de `out_data[4]` para `00`.


### Caso D — Rota dinâmica

Critério: 
- determinismo por ciclo
- sem requisito de framing/fim de mensagem (avaliação por amostragem no testbench)

Objetivo: 
- Demonstrar que alterações em `route_tb` durante data streaming em `in_data_tb` são refletidas imediatamente.
- Controle e amostragem pelo driver do testbench

State table estimada:

| Ciclo | route_tb[0..7]      | output_enable_tb[0..7] | collision_error | in_data_tb[0..7]            | out_data[0..7] esperado     |
| ----: | ------------------- | ------------------- | --------------: | --------------------------- | --------------------------- |
|    T0 | `[0,6,0,0,0,0,0,0]` | `[0,1,0,0,0,0,0,0]` |               0 | `[10,21,32,43,54,65,76,87]` | `[00,76,00,00,00,00,00,00]` |
|    T1 | `[0,7,0,0,0,0,0,0]` | `[0,1,0,0,0,0,0,0]` |               0 | `[90,91,92,93,94,95,11,22]` | `[00,22,00,00,00,00,00,00]` |
|    T2 | `[0,0,0,0,0,0,0,0]` | `[0,1,0,0,0,0,0,0]` |               0 | `[33,44,55,66,77,88,99,AA]` | `[00,33,00,00,00,00,00,00]` |
- Nota desse caso proposto: 
	- usar apenas uma saída habilitada (j=1) para isolar o efeito de reconfiguração dinâmica no mapeamento.


### Caso Adicionais: Proposições em aberto 
- Dinâmica + colisão variando no tempo 
	- Critério: collision_error acompanha controle em tempo real

Objetivo: 
- demonstrar o que ocorre quando:
	- a transição de `collision_error` ao alternar entre:
	- rotas diferentes (sem colisão),
	- rotas iguais (com colisão),
	- mascaramento por disable (colisão deixa de contar).

State table estimada

| Ciclo | route_tb[0..7]      | output_enable_tb[0..7] | collision_error | in_data_tb[0..7]            | out_data[0..7] esperado     |
| ----: | ------------------- | ------------------- | --------------: | --------------------------- | --------------------------- |
|    T0 | `[1,0,0,3,0,0,0,0]` | `[1,0,0,1,0,0,0,0]` |               0 | `[10,21,32,43,54,65,76,87]` | `[21,00,00,43,00,00,00,00]` |
|    T1 | `[2,0,0,2,0,0,0,0]` | `[1,0,0,1,0,0,0,0]` |               1 | `[90,91,92,93,94,95,96,97]` | `[92,00,00,92,00,00,00,00]` |
|    T2 | `[4,0,0,4,0,0,0,0]` | `[1,0,0,0,0,0,0,0]` |               0 | `[A0,A1,A2,A3,A4,A5,A6,A7]` | `[A4,00,00,00,00,00,00,00]` |

Verificar que:
- T0: saídas 0 e 3 habilitadas, `route_tb[0]=1` e `route_tb[3]=3` -> sem colisao.
- T1: saídas 0 e 3 habilitadas, `route_tb[0]=route_tb[3]=2` -> colisao imediata, `collision_error=1`.
- T2: `route_tb[0]=route_tb[3]=4`, mas a saída 3 esta desabilitada -> colisao mascarada, `collision_error=0`.




## Atendimento de requisitos

O plano é considerado atendido quando:
- todos os casos mínimos (A-D) passam sem divergências no scoreboard;
- `collision_error` respeita a definição formal em todos os vetores aplicados;
- o comportamento observado é determinístico e reproduzível com amostragem definida.

## Resumo

- Seleção independente por saída (rotas simultâneas): Caso A
- Detecção de colisão (somente saídas habilitadas): Casos B e C
- output_enable enable/disable modula saídas do crossbar para zero: Caso C
- Determinismo sob reconfiguração dinâmica: Caso D


# Checklist geral

## DUT (Crosspoint System) - TEST
-  Caso A - 4 saídas simultâneas roteiam corretamente e `collision_error=0`
	- [ ] (PASS)
	- [ ] (FAIL)
-  Caso B - (Pass) - `collision_error=1` **com duas** saídas habilitadas apontando para a mesma entrada.
	- [ ] (PASS)
	- [ ] (FAIL)
-  Caso C - Saída desabilitada permanece em zero e colisão e mascarada por disable.
	- [ ] (PASS)
	- [ ] (FAIL)
-  Caso D - Saída habilitada acompanha `route_tb` e `in_data_tb` por ciclo (determinismo requerido).
	- [ ] (PASS) 
	- [ ] (FAIL) 
-  Caso Adicional - `collision_error` tenha características de transições (0->1->0) em conformidade aos estados sequenciais de `route_tb` e `output_enable_tb`.
	- [ ] (PASS)
	- [ ] (PASS)

## Barrel-shifter Module - TEST
...

## Crossbar NxN Module - TEST
...

## Collision Monitor Module - TEST
...
