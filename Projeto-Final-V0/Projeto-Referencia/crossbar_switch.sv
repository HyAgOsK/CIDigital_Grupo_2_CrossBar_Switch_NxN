// MÓDULO TOP-LEVEL

module crossbar_switch #(
	parameter N = 8,  // Quantidade de portas de entrada do switch
	parameter W = 8   // Tamanho do barramento de cada porta do switch
)(
    input wire clk,                                 // Clock
    input wire [N-1:0] [W-1:0] in,                  // Portas de entrada do switch
	input wire [N-1:0] [$clog2(N)-1:0] input_sel,   // Seletores de portas de entrada (a ser utilizado pelas portas de saída)
	input wire [N-1:0] output_enable,               // Ativadores das portas de saída do switch
	output wire [N-1:0] [W-1:0] out,                // Portas de saída do switch
	output wire mapping_error,                      // Sinal de erro de mapeamento (mapeamento de portas não permitido pelo Barrel Shifter)
	output wire collision_error                     // Sinal de erro de colisão (duas ou mais saídas escolheram a mesma entrada)
);

	// TODO

	// Instanciar módulos:
	//   > crossbar_switch_mapping_monitor
	//   > crossbar_switch_barrel_shifter

	// Integrar sinais:
	//   1) crossbar_switch_mapping_monitor assíncrono
	//   2) clk e crossbar_switch_barrel_shifter síncrono (o crossbar switch barrel shifter DEVE RESPEITAR O MONITOR)

	// Implementar lógica do "output_enable" assíncrono
	// Zerar saídas não requisitadas, mesmo que o sinal de controle "output_enable" esteja ativado
	// Zerar todas as saidas em caso de erro (mapping_error ou collision_error)

endmodule