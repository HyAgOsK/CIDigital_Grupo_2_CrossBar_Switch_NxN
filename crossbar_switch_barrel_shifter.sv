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
	genvar k;
	generate
	    for (k = 0; k < N; k = k + 1) begin: G_ROT
			// out[k] recebe in[(k + shift) % N]
			// shift=0 -> out = in
			// shift=1 -> escolha de entrada vai para saída,  out[0]=in[1], out[1]=in[2] ..., out[N-1]=in[0]
			assign out[k] = in[(k + shift) % N];
		end
	endgenerate

endmodule
