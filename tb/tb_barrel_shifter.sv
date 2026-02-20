`timescale 1ns/1ps

module tb_barrel_shifter;

  localparam int N = 8;
  localparam int ROUTE_BITS = $clog2(N);

  logic [ROUTE_BITS-1:0] route [N];
  logic [N-1:0]          select_SE [N];

  barrel_shifter #(.N(N)) dut (
    .route(route),
    .select_SE(select_SE)
  );

  // conta quantos bits "1" existem em um vetor
  function automatic int ones(input logic [N-1:0] v);
    int c = 0;
    for (int i = 0; i < N; i++) if (v[i]) c++;
    return c;
  endfunction

  // imprime rotas e select_SE
  task automatic show(string title);
    $display("\n---------------- %s ----------------", title);
    $write("route: ");
    for (int j = 0; j < N; j++) $write("[%0d]=%0d ", j, route[j]);
    $write("\n");
    for (int j = 0; j < N; j++) $display("select_SE[%0d] = %b", j, select_SE[j]);
  endtask

  // checa contrato: one-hot e bit do route ligado
  task automatic check(string title);
    bit ok = 1;

    show(title);

    for (int j = 0; j < N; j++) begin
      if (ones(select_SE[j]) != 1) begin
        ok = 0;
        $display("ERRO: linha %0d não é one-hot (select=%b)", j, select_SE[j]);
      end

      if (select_SE[j][int'(route[j])] !== 1'b1) begin
        ok = 0;
        $display("ERRO: linha %0d route=%0d mas bit não está em 1 (select=%b)",
                 j, route[j], select_SE[j]);
      end
    end

    if (!ok) $fatal(1);
    else     $display("OK");
  endtask

  initial begin
    // Caso 1: identidade (cada saída j seleciona entrada j)
    for (int j = 0; j < N; j++) route[j] = j;
    #1;
    check("Caso 1: Identidade (route[j]=j)");

    // Caso 2: todo mundo seleciona entrada 0 (one-hot continua certo)
    // (colisão NÃO é responsabilidade do barrel_shifter, e sim do collision_monitor)
    for (int j = 0; j < N; j++) route[j] = 0;
    #1;
    check("Caso 2: Todos em 0 (route[j]=0)");

    // Caso 3: rotas diferentes ao mesmo tempo (simultâneo)
    // exemplo: [3,1,7,0,2,6,5,4]
    route[0]=3; route[1]=1; route[2]=7; route[3]=0;
    route[4]=2; route[5]=6; route[6]=5; route[7]=4;
    #1;
    check("Caso 3: Rotas distintas simultâneas");

    // Caso 4: reconfiguração dinâmica (troca sem clock, DUT é combinacional)
    // muda o vetor route e confere que select_SE acompanha
    route[0]=0; route[1]=0; route[2]=0; route[3]=0;
    route[4]=0; route[5]=0; route[6]=0; route[7]=0;
    #1;
    check("Caso 4a: Antes (tudo 0)");

    route[0]=7; route[1]=6; route[2]=5; route[3]=4;
    route[4]=3; route[5]=2; route[6]=1; route[7]=0;
    #1;
    check("Caso 4b: Depois (reconfigurado)");

    $display("\nFIM: tb_barrel_shifter passou");
    $finish;
  end

endmodule
