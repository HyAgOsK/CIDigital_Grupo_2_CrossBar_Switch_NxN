
# Pipeline

Pipeline de desenvolvimento das etapas de design, test and verification é proposto pela sugestão de recursos mínimos necessários para o desenvolvimento e execução das atividades relativas ao Trabalho Orientado I. Desse modo, estabelecem-se os critérios, versões e sugestões para tal.


Project pipeline:
- IDE tool 🠲 HDL toolchain 🠲 local repo 🠲 Github

## RTL

- SystemVerilog
	- IEEE 1364-2005 and 1364-1995 (Verilog)
	- IEEE 1800-2012, 1800-2009 and 1800-2005 (SystemVerilog)
- Mentor ModelSim - Intel FPGA Starter Edition 2020.1 Rev. 2020.02 - feb, 28 2020
	
### ModelSim

Referências presentes em `docs/`
    - GUI Reference Manual
    - Command Reference Manual
    - Tutorial
    - User's Manual

> [!NOTE] User Manual Note (adaptado) 
> ModelSim supports partial implementation of SystemVerilog IEEE Std 1800-2012. For release-specific information on currently supported implementation, refer to the following text file: *"docs/ModelSim/sysvlog.note.md"* 

## VScode

Recomenda-se vscode como IDE de desenvolvimento, pois:
    - Integração rápida com GitHub
    - Contém extensões de renderização de Markdown
    - Integra CLI

## Estrutura de diretórios:

A estrutura proposta baseia-se na separação por propósito. O objetivo é segregar as etapas de design e verificação dos artefatos e scripts das ferramentas de desenvolvimento, além de organizar os resultados obtidos. Essa abordagem visa consolidar a padronização do fluxo, independentemente da máquina onde for executado.


```
Trabalho Orientado - I/
├── .gitignore                    
├── Makefile                      (Script automation)
├── README.md
|
|
├── docs/
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


#### Propósito individual:

- Projeto/ (Root):
  - .gitignore: 
      - Arquivo de referência que aponta quais diretórios ou arquivos ignorar pela ferramenta de versionamento.

  - README.md: 
    - Apresenta de maneira concisa o que está no projeto e como executar Makefiles dos tb.

  - doc/:
    - Contém toda documentação de referência, análise de projeto, especificações, requisitos, diagramas, datasheets e notas diversas.

  - rtl/:
    - Contem os design files dos módulos sintetizáveis do projeto (.v, .sv).

  - tb/ (Testbench):
    - Todos os códigos de teste e verificação utilizados para validar o Test and Verification Plan.

  - scripts/:
    - Scripts de automação (tcl/sh)

  - sim/, synth/:
    - Relativos aos workspaces. Repositório de arquivos utilizados e produzidos nas etapas de simulatção/sintetização.

  - reports/:
    - Repositório de resultados de simulação, logs de compiladores, resultados de scoreboard, testes diversos e etc. Scripts de automação **devem** apontar os outputs para cá.
