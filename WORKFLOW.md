# Análise de Workflow

# Pipeline

Este documento define o pipeline de desenvolvimento para as etapas de design, teste e verificação do Trabalho Orientado I. Estabelece os recursos mínimos necessários, critérios, versões e recomendações.

Fluxo do projeto:

- IDE tool → HDL toolchain → repositório local → Github

## RTL

- SystemVerilog
    - IEEE 1364-2005 e 1364-1995 (Verilog)
    - **IEEE 1800-2012, 1800-2009 e 1800-2005 (SystemVerilog)**
- Mentor ModelSim — Intel FPGA Starter Edition 2020.1 Rev. 2020.02 — 28 de fevereiro de 2020

### ModelSim

Referências presentes em `docs/`

- GUI Reference Manual
- Command Reference Manual
- Tutorial
- User's Manual

> [!NOTE] User Manual Note (adaptado)
ModelSim supports partial implementation of SystemVerilog IEEE Std 1800-2012. For release-specific information on currently supported implementation, refer to the following text file: *"docs/ModelSim/sysvlog.note.md"*
> 

## VScode

Recomenda-se VSCode como IDE de desenvolvimento pelos seguintes motivos:

- Integração rápida com GitHub
- Extensões de renderização de Markdown
- Integração com CLI

## Estrutura de diretórios

A estrutura proposta separa arquivos por propósito. O objetivo é segregar as etapas de design e verificação dos artefatos e scripts das ferramentas de desenvolvimento, além de organizar os resultados obtidos. Essa abordagem padroniza o fluxo, independentemente da máquina onde for executado.

```
Trabalho Orientado - I/
├── .gitignore
├── Makefile                      (Script automation)
├── README.md
|
|
├── doc/
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
│   └── Makefile                  (makefilel-&gt;scripts/run_sim e etc)
│
├── synth/
│   └── Makefile                  (Tudo depende...)
│
└── reports/                      (Relatórios dos testes e verificações)
    ├── sim/
    └── synth/
```

### Propósito individual

- Projeto/ (Root):
    - .gitignore:
        - Define quais diretórios ou arquivos a ferramenta de versionamento deve ignorar.
    - [README.md](http://readme.md/):
        - Apresenta de forma concisa o conteúdo do projeto e como executar os Makefiles dos testbenches.
    - doc/:
        - Contém toda a documentação de referência, análise de projeto, especificações, requisitos, diagramas, datasheets e notas diversas.
    - rtl/:
        - Contém os arquivos de design dos módulos sintetizáveis do projeto (.v, .sv).
    - tb/ (Testbench):
        - Todos os códigos de teste e verificação utilizados para validar o Test and Verification Plan.
    - scripts/:
        - Scripts de automação (tcl/sh).
    - sim/, synth/:
        - Workspaces. Repositório de arquivos utilizados e produzidos nas etapas de simulação/sintetização.
    - reports/:
        - Repositório de resultados de simulação, logs de compiladores, resultados de scoreboard e outros testes. Scripts de automação **devem** direcionar os outputs para este diretório.
