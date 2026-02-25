// descreva aqui o Testbench simples para validar...
`timescale 1ns/1ps

module tb_barrel_shifter;

  parameter N = 4;
  parameter ROUTE_BITS = $clog2(N);

  reg  [N*ROUTE_BITS-1:0] route_flat;
  wire [N*N-1:0]          select_SE_flat;

  // Instancia DUT
  barrel_shifter #(
    .N(N),
    .ROUTE_BITS(ROUTE_BITS)
  ) dut (
    .route_flat(route_flat),
    .select_SE_flat(select_SE_flat)
  );

  initial begin


    // -------------------------------
    // CASO 1: Todas saídas -> entrada 0
    // route = {0,0,0,0}
    // -------------------------------
    route_flat = 8'b00000000;
    #10;

    // -------------------------------
    // CASO 2: Identidade
    // route[0]=0
    // route[1]=1
    // route[2]=2
    // route[3]=3
    // -------------------------------
    route_flat = {2'b11, 2'b10, 2'b01, 2'b00};
    #10;

    // -------------------------------
    // CASO 3: Invertido
    // route[0]=3
    // route[1]=2
    // route[2]=1
    // route[3]=0
    // -------------------------------
    route_flat = {2'b00, 2'b01, 2'b10, 2'b11};
    #10;

    // -------------------------------
    // CASO 4: Rota inválida
    // route[3]=4 (100 binário)
    // como ROUTE_BITS=2, 4 vira 00 (overflow)
    // então vamos simular inválido manualmente
    // -------------------------------
    route_flat = {2'b11, 2'b01, 2'b00, 2'b10};
    #10;

    $finish;
  end

endmodule
