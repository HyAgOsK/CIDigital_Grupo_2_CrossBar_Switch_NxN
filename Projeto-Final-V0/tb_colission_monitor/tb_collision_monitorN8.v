`timescale 1ns/1ps

module tb_collision_monitor;

  parameter N = 8;
  parameter ROUTE_BITS = $clog2(N);

  reg  [N*ROUTE_BITS-1:0] route_flat;
  reg  [N-1:0]            output_enable;
  wire                    collision_error;

  // Instancia DUT
  collision_monitor #(
    .N(N),
    .ROUTE_BITS(ROUTE_BITS)
  ) dut (
    .route_flat(route_flat),
    .output_enable(output_enable),
    .collision_error(collision_error)
  );

  initial begin
    $display("==== INICIO TESTE collision_monitor ====");
    $monitor("output_enable=%b_%b | route_flat=%b_%b_%b_%b_%b_%b_%b_%b | collision_error=%b",
             output_enable[7:4], output_enable[3:0],
			 route_flat[23:21], route_flat[20:18], route_flat[17:15], route_flat[14:12], route_flat[11:9], route_flat[8:6], route_flat[5:3], route_flat[2:0],
			 collision_error);

    // ------------------------------------------
    // CASO 1: Todas saídas desabilitadas
    // Mesmo com rotas iguais, NÃO deve dar colisão
    // ------------------------------------------
    route_flat     = {3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd0, 3'd0};
    output_enable  = 8'd0;
    #10;

    // ------------------------------------------
    // CASO 2: Todas habilitadas, rotas diferentes (identidade)
    // route[0]=0, route[1]=1, route[2]=2, route[3]=3, ...
    // NÃO deve dar colisão
    // ------------------------------------------
	route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0};
    output_enable  = 8'b1111_1111;
    #10;

    // ------------------------------------------
    // CASO 3: Colisão entre duas saídas habilitadas
    // route[0]=1 e route[1]=1 -> colisão
    // ------------------------------------------
	route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd1};
    output_enable  = 8'b1111_1111;
    #10;

    // ------------------------------------------
    // CASO 4: Rotas iguais, mas uma saída desabilitada
    // route[0]=1 e route[1]=1, porém output_enable[1]=0
    // NÃO deve dar colisão
    // ------------------------------------------
    route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd1};
    output_enable  = 8'b1111_1101; // saída 1 desabilitada
    #10;

    // ------------------------------------------
    // CASO 5: Múltiplas colisões
    // route[0]=3, route[1]=3 e route[2]=0, route[3]=0
    // Deve dar colisão
    // ------------------------------------------
    route_flat     = {2'b00, 2'b00, 2'b11, 2'b11};
	route_flat     = {3'd7, 3'd6, 3'd5, 3'd4, 3'd0, 3'd0, 3'd3, 3'd3};
    output_enable  = 8'b1111_1111;
    #10;

    $display("==== FIM TESTE collision_monitor ====");
    $finish;
  end

endmodule