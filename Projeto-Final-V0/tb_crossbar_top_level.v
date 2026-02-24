`timescale 1ns/1ps

module tb_crossbar_top_level;

  // Verilog-2001 (sem int / sem clog2)
  localparam N = 8;
  localparam W = 8;
  localparam ROUTE_BITS = clog2(N); // clog2(8)=3

  // Macros para acessar vetores flatten


  // Clock só para controle/amostragem do testbench
  reg clk_tb;
  initial clk_tb = 1'b0;
  always #5 clk_tb = ~clk_tb;

  // Estímulos TB (flatten)
  reg  [N*W-1:0]          in_data_tb;
  reg  [N*ROUTE_BITS-1:0] route_tb;
  reg  [N-1:0]            output_enable_tb;

  // Saídas DUT (flatten)
  wire [N*W-1:0]          out_data_dut;
  wire                    collision_error_dut;

  // Scoreboard (modelo de referência)
  reg  [N*W-1:0]          expected_out_flat;
  reg                     expected_collision;


  integer checks;
  integer fails;

  // Instância do DUT (versão Verilog flatten)
  crossbar_top_level #(
    .N(N),
    .W(W),
    .ROUTE_BITS(ROUTE_BITS)
  ) dut (
    .in_data_flat(in_data_tb),
    .route_flat(route_tb),
    .output_enable(output_enable_tb),
    .out_data_flat(out_data_dut),
    .collision_error(collision_error_dut)
  );

  // Modelo de referência

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------
  // ... A elaborar

  // ---------------------------------------------------------------------------
  // Estímulos
  // ---------------------------------------------------------------------------
  // ... A elaborar

  initial begin
    checks = 0;
    fails  = 0;

    // Inicialização
    in_data_tb       = {N*W{1'b0}};
    route_tb         = {N*ROUTE_BITS{1'b0}};
    output_enable_tb = {N{1'b0}};


    // ---------------- Caso A — 4 rotas simultâneas (sem colisão) ----------------


    // ---------------- Caso B — colisão forçada ----------------


    // ---------------- Caso C — enable/zero + colisão mascarada ----------------


    // ---------------- Caso D — rota dinâmica (uma saída habilitada) ----------------

    $finish;
  end

endmodule
