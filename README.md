# Crosspoint Switch NxN - Trabalho Orientado I

_Sugestão de alteração de nome para explicitar que não é sobre um crossbar, mas um dispositivo completo para uma determinada aplicação que utiliza dessa interconexão._

## Topology overview

``` text
Control Domain
     Zone

                +------------------crossbar_system #(N=2^k, W)----------------------+
                |                                                                   |
                | Inputs: in_data[N][W], route[N][ROUTE_BITS], output_enable[N]     |
                | Outputs: out_data[N][W], collision_error                          |
                |                                                                   |
                |                                                                   |
output_enable[N]-----------+------------------------> +---------------------+       |
                |   +------|------------------------> |   collision_monitor |----------> collision_error
                |   |      |                          +---------------------+       |        (flag)
                |   |      |                                                        |
                |   |      |       +-----------------------+                        |
                |   |      |       | barrel_shifter        |----> select_SE[N][N]   |
route[N]    ----+---|------------> |(controle do crossbar) |          |             |
[ROUTE_BITS]    |          |       +-----------------------+          v             |
                |          |                                  +------------------+  |
in_data[N][W]--------------|--------------------------------> | crossbar_nxn     |--|--> out_data[N][W]
(input stream)  |          +--------------------------------> | (datapath)       |  |    (output stream)
                |                                             | + enable/zero    |  |
                |                                             +------------------+  |
                +-------------------------------------------------------------------+
```

## 1. Considerações

Este documento consolida a especificação e a topologia de um sistema de interconexão NxN, com:
- Comutação baseada no modulo `barrel_shifter` (arquitetura de barrel shifters aplicada ao plano de controle para gerar `select_SE`).
- Monitoramento independente de colisão em tempo real.
- Sistema modular, parametrizável e segmentado entre:
  - Control Domain / Supervisório (fora do escopo)
  - plano de CONTROLE (em escopo)
  - plano de DATAPATH (em escopo)
  - plano de MONITORAMENTO (em escopo)

## Sistema modular e segmentado em domínios/plano de responsabilidade:

- Control Domain/ Supervisório (fora do escopo):
	- Determina:
		- `route[N][ROUTE_BITS]` (politica de roteamento por saída) 
		- `output_enable[N]` (politica de habilitação por saída).
	  - Orquestra o streaming, segundo regras/politicas externas não especificadas neste projeto, por:
		  -  `in_data[N][W]` (data streaming)

- Plano de CONTROLE (em escopo, nível `crossbar_system`):
  - `barrel_shifter`:
    - Converte `route[N][ROUTE_BITS]` em `select_SE[N][N]` (one-hot de Switching Elements), que comanda fisicamente a matriz de comutação.

- Plano de DATAPATH (em escopo, nível `crossbar_system`):
  - `crossbar_nxn`:
    - Comuta `in_data` usando `select_SE`.
    - Aplica `output_enable` como gate final (saída forcada a zero quando desabilitada).

- Plano de MONITORAMENTO (em escopo, nível `crossbar_system`):
  - `collision_monitor`:
    - Monitora `route` e `output_enable` em tempo real e sinaliza `collision_error` conforme a definição formal.

## Pressupostos:
- Sem `ACK/valid/ready`, framing, sem requisito de finalização de transferência nas comutações de rotas.
	- Pressupõe-se autoridade do Controlador de domínio. Fora do escopo.
- Vetor de rota do data streaming
	- Pressupõe-se autoridade do Controlador de domínio. Fora do escopo.
- Restrição imposta: `N = 2^k`.
	- Critério não estabelecido nas especificações.

## Considerações
### Observação para verificação:
- O DUT (`crossbar_system`) não possui porta de clock e é tratado como combinacional;
	- Clock port restringe-se ao Test and Verification Plan/Control domain para:
		- imposição de determinismo e validação do cumprimento dos requisitos mínimos de teste
		- Sincronização da aplicação implementada final

### Workflow
- Para o pipeline de desenvolvimento das etapas de design, test and verification define-se:
	- SystemVerilog
		- IEEE 1364-2005 and 1364-1995 (Verilog)
		- **IEEE 1800-2012, 1800-2009 and 1800-2005 (SystemVerilog)**
	- Mentor ModelSim - Intel FPGA Starter Edition 2020.1 Rev. 2020.02 - feb, 28 2020


### Estrutura de diretórios:

Baseia-se na separação por propósito. O objetivo é segregar as etapas de design e verificação, bem como os artefatos e scripts das ferramentas de desenvolvimento, além de organizar os resultados gerados. Essa abordagem visa consolidar a padronização do fluxo, independentemente da máquina em que for executado.

```
Trabalho Orientado - I/
├── .gitignore                    (Veja considerações associadas)
├── Makefile                      (Script automation)
├── README.md
|
|
├── doc/                          (datasheets, manuais, standards, notas)
│   └── Project.md
│
├── rtl/
│   ├── barrel_shifter.sv         (Subsystem module)
│   ├── crossbar_nxn.sv           (Subsystem module)
│   ├── collision_monitor.sv      (Subsystem module)
│   └── crossbar_system.sv        (System integration module)
│
├── tb/
│   ├── tb_barrel_shifter.sv      (Specific subsystem module testbench)
│   ├── tb_crossbar_nxn.sv        (Specific subsystem module testbench)
│   ├── tb_colission_monitor.sv   (Specific subsystem module testbench)
│   └── tb_crossbar_system.sv     (System Testbench)            
│
├── scripts/                       ──────────────────────────────────────
│   └── run_sim.tcl/sh         <--| Automatiza e determina os tipos,     |
│   ...                           | sequencias e parâmetros seguindo o   |
│                                 |    Test And Verification Plan.md     |
│                                  ──────────────────────────────────────
├── sim/
│   └── Makefile                  (makefilel->scripts/run_sim e etc)
│
├── synth/
│   └── Makefile                  (Tudo depende...)
│
└── reports/                      (Relatórios dos testes e verificações)
    ├── sim/
    └── synth/
```

- *Mais informações em* ***Análise de Workflow***

## 2. Definições e requisitos

### 2.1 Parâmetros

- `N`: numero de portas de entrada e saída.
- `W`: largura do dado em bits.
- Restrição: `N = 2^k`.

Parâmetro derivado:
- `ROUTE_BITS = $clog2(N)`: Largura de bits do índice `route[j]`
	- `localparam int ROUTE_BITS = $clog2(N);`

### 2.2 Sinais / Ports

- `in_data[i]`: entrada `i`, `i in [0..N-1]`, largura `W`.
- `out_data[j]`: saída `j`, `j in [0..N-1]`, largura `W`.
- `route[j]`: índice de rota de dados (plano de controle), largura `S`.
- `select_SE[j][i]`: sinal de Switching Element (plano de controle físico do crossbar).
  - `select_SE[j][i] = 1` indica que a entrada `i` deve ser conectada a saída `j`.
- `output_enable[j]`: habilita a saída `j`.
- `collision_error`: flag global de colisão.

### 2.3 Seleção independente por saída

- Cada saída `j` possui seu próprio `route[j]`.
- Deve ser possível configurar rotas distintas e simultâneas no mesmo ciclo.

### 2.4 Habilitação de saída (output_enable)

- Se `output_enable[j] == 0`, então `out_data[j]` deve ser forcada a zero, independentemente de rota e de `in_data[*]`.
- Se `output_enable[j] == 1`, então `out_data[j]` deve refletir a rota selecionada.

### 2.5 Detecção de colisão (collision_error)

- O hardware deve monitorar os seletores em tempo real.
- Colisão é definida apenas entre saídas habilitadas.



