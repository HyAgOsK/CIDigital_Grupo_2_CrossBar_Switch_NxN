`timescale 1ns / 1ps

module barrel_shifter_tb();

	parameter N = 8;
	parameter ROUTE_BITS = $clog2(N);

	reg [N*ROUTE_BITS-1:0] route_flat;
	wire [N*N-1:0] select_SE_flat;

	barrel_shifter #(
		.N(N),
		.ROUTE_BITS(ROUTE_BITS)
	) DUT (
		.route_flat(route_flat),
		.select_SE_flat(select_SE_flat)
	);

	initial begin
		$monitor("Rotas: %b_%b_%b_%b_%b_%b_%b_%b | Matriz One-Hot: %b_%b_%b_%b_%b_%b_%b_%b",
			route_flat[23:21], route_flat[20:18], route_flat[17:15], route_flat[14:12], route_flat[11:9], route_flat[8:6], route_flat[5:3], route_flat[2:0],
			select_SE_flat[63:56], select_SE_flat[55:48], select_SE_flat[47:40], select_SE_flat[39:32], select_SE_flat[31:24], select_SE_flat[23:16], select_SE_flat[15:8], select_SE_flat[7:0]);

		// Vetor de rotas: {rota8, rota7, rota6, rota5, rota4, rota3, rota2, rota1, rota0}
		// {7, 6, 5, 4, 3, 2, 1, 0}
		$display("ROTA VALIDA: {7, 6, 5, 4, 3, 2, 1, 0}");
		route_flat = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
		#10;

		// {5, 4, 3, 2, 1, 0, 7, 6}
		$display("\nROTA VALIDA: {5, 4, 3, 2, 1, 0, 7, 6}");
		route_flat = {3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0, 3'd7, 3'd6};
		#10;

		// {5, 4, 3, 2, 1, 0, 6, 7} (Rota inválida)
		$display("\nROTA INVALIDA: {5, 4, 3, 2, 1, 0, 6, 7}");
		route_flat = {3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0, 3'd6, 3'd7};
		#10;

		// Importante:
		// Por definição, um CROSSBAR SWITCH BARREL SHIFTER suporta apenas N combinações de mapeamentos.
		//    Enquanto que um CROSSBAR SWITCH TRADICIONAL suporta todas as N! combinações de mapeamentos.
		// https://en.wikipedia.org/wiki/Barrel_shifter
	end

endmodule
