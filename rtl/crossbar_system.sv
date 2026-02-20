// MÓDULO TOP-LEVEL

module crossbar_system_top #(
  parameter int N = 8,          // N = 2^k
  parameter int W = 8,
  localparam int ROUTE_BITS = $clog2(N)
) (
  input  logic [W-1:0] in_data       [N],
  input  logic [S-1:0] route         [N],
  input  logic         output_enable [N],
  output logic [W-1:0] out_data      [N],
  output logic         collision_error
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
