// MÓDULO DE MONITORIA

module crossbar_switch_mapping_monitor #(
	parameter N = 8  // Quantidade de portas de entrada do switch
)(
	input wire [N-1:0] [$clog2(N)-1:0] input_sel,  // Seletores de portas de entrada (a ser utilizado pelas portas de saída)
	output wire [$clog2(N)-1:0] shift,             // Quantidade de deslocamento circular a ser feito pelo barrel-shifter
	output wire mapping_error,                     // Sinal de erro de mapeamento (mapeamento de portas não permitido pelo Barrel Shifter)
	output wire collision_error                    // Sinal de erro de colisão (duas ou mais saídas escolheram a mesma entrada)
);

	// 	TODO

	//  Criar lookup table para armazenar as possíveis combinações de saídas cheias suportadas pelo Barrel Shifter no atual valor de N

	//  Calcular deslocamento circular (shift) a ser feito pelo Barrel Shifter
	//     > Tratar corretamente os casos onde apenas algumas portas são requisitadas (requested ports + null ports)

	//  Detectar eventuais mapeamentos não suportados pelo Barrel Shifter (mapping_error)
	//  Detectar eventuais colisões de portas (collision_error)

endmodule