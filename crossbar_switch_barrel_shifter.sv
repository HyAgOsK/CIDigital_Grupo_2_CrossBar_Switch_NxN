// MÓDULO BARREL-SHIFTER

module crossbar_switch_barrel_shifter #(
	parameter N = 8,  // Quantidade de portas de entrada do switch
	parameter W = 8   // Tamanho do barramento de cada porta do switch
)(
    input wire [N-1:0] [W-1:0] in,     // Portas de entrada do switch
	input wire [$clog2(N)-1:0] shift,  // Quantidade de deslocamento circular a ser feito pelo barrel-shifter
	output wire [N-1:0] [W-1:0] out    // Portas de saída do switch
);

	// 	TODO

	// Lógica do crossbar switch usando barrel-shifter

endmodule