// MÓDULO DE MONITORIA

module collision_monitor #(
  parameter int N = 8,          // N = 2^k
  localparam int ROUTE_BITS = $clog2(N)
) (
  input  logic [S-1:0] route         [N],
  input  logic         output_enable [N],
  output logic         collision_error
);

	// 	TODO

	//  Criar lookup table para armazenar as possíveis combinações de saídas cheias suportadas pelo Barrel Shifter no atual valor de N

	//  Calcular deslocamento circular (shift) a ser feito pelo Barrel Shifter
	//     > Tratar corretamente os casos onde apenas algumas portas são requisitadas (requested ports + null ports)

	//  Detectar eventuais mapeamentos não suportados pelo Barrel Shifter (mapping_error)
	//  Detectar eventuais colisões de portas (collision_error)

endmodule
