module crossbar_switch_barrel_shifter #(
	parameter N = 8,  // Quantidade de portas de entrada do switch
	parameter W = 8   // Tamanho do barramento de cada porta do switch
)(
    input wire [N-1:0] [W-1:0] in,     // Portas de entrada do switch
	input wire [$clog2(N)-1:0] shift,  // Quantidade de deslocamento circular a ser feito pelo barrel-shifter
	output wire [N-1:0] [W-1:0] out    // Portas de saída do switch
);

	// VERSÃO UNIFICADA
	// CONTRIBUIÇÕES DE: LUCAS, HYAGO, BRUNO NASSAR
	// Crossbar switch barrel shifter NxN:
	//  * Quantidade de muxes: N muxes Nx1 em uma única camada;
	//  * Pontos de interseção: N²;
	//  * Complexidade do atraso de propagação: O(1);
	//  * Fan-out dos buffers de entrada: N;
	//  * Conversor de código:
	//    - Entrada: "shift";
	//    - Saídas: sinais que controlam os seletores dos muxes.

	wire [2*N-1:0] [W-1:0] in_double;
	assign in_double = {in, in};

	genvar k;
	generate
		// Criação dos N muxes (crossbar switch de 1 camada de muxes)
		for (k = 0; k < N; k = k + 1) begin: MUX
			assign out[k] = in_double[k + shift];
		end
	endgenerate

	// // CONTRIBUIÇÃO DE: HYAGO
	// genvar k;
	// generate
	//     for (k = 0; k < N; k = k + 1) begin: G_ROT
	// 		assign out[k] = in[(k + shift) % N];
	// 	end
	// endgenerate

	// // CONTRIBUIÇÃO DE: LUCAS
	// wire [ 2 * N - 1 : 0] double_in;
	//
    // assign double_in = { in , in};      //Duplica a entrada para permitir a rotação, tornando o código sintetizavel
    // assign out = double_in >> shift ;   //Realiza o deslocamento dos valores conforme o valor de shift, entregando a saída no valor desejado

endmodule