`timescale 1ns/1ps

module tb_collision_monitor;

  parameter N = 4;
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
    $monitor("t=%0t | output_enable=%b | route_flat=%b | collision_error=%b",
             $time, output_enable, route_flat, collision_error);

    // ------------------------------------------
    // CASO 1: Todas saídas desabilitadas
    // Mesmo com rotas iguais, NÃO deve dar colisão
    // ------------------------------------------
    route_flat     = {2'b00, 2'b00, 2'b00, 2'b00};
    output_enable  = 4'b0000;
    #10;

    // ------------------------------------------
    // CASO 2: Todas habilitadas, rotas diferentes (identidade)
    // route[0]=0, route[1]=1, route[2]=2, route[3]=3
    // NÃO deve dar colisão
    // ------------------------------------------
    route_flat     = {2'b11, 2'b10, 2'b01, 2'b00};
    output_enable  = 4'b1111;
    #10;

    // ------------------------------------------
    // CASO 3: Colisão entre duas saídas habilitadas
    // route[0]=1 e route[1]=1 -> colisão
    // ------------------------------------------
    route_flat     = {2'b11, 2'b10, 2'b01, 2'b01};
    output_enable  = 4'b1111;
    #10;

    // ------------------------------------------
    // CASO 4: Rotas iguais, mas uma saída desabilitada
    // route[0]=2 e route[1]=2, porém output_enable[1]=0
    // NÃO deve dar colisão
    // ------------------------------------------
    route_flat     = {2'b00, 2'b01, 2'b10, 2'b10};
    output_enable  = 4'b1101; // saída 1 desabilitada
    #10;

    // ------------------------------------------
    // CASO 5: Múltiplas colisões
    // route[0]=3, route[1]=3 e route[2]=0, route[3]=0
    // Deve dar colisão
    // ------------------------------------------
    route_flat     = {2'b00, 2'b00, 2'b11, 2'b11};
    output_enable  = 4'b1111;
    #10;

    $display("==== FIM TESTE collision_monitor ====");
    $finish;
  end

endmodule
