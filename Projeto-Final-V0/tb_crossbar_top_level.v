`timescale 1ns/1ps

module tb_crossbar_top_level;

  // Verilog-2001 (sem int / sem $clog2)
  localparam N = 8;
  localparam W = 8;
  localparam ROUTE_BITS = clog2(N); // clog2(8)=3

  // Macros para acessar vetores flatten
  `define IN(i)      in_data_tb[(i)*W +: W]
  `define ROUTE(i)   route_tb[(i)*ROUTE_BITS +: ROUTE_BITS]
  `define OUT(i)     out_data_dut[(i)*W +: W]
  `define EXP(i)     expected_out_flat[(i)*W +: W]

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

  // Debug TB (ótimo para waves)
  // requesters_per_input_dbg[i][j] = saída j está habilitada e requisitando entrada i
  reg [N-1:0] requesters_per_input_dbg [0:N-1];
  reg [N-1:0] collision_on_input_dbg;    // marca entradas com 2+ requisitantes
  reg         any_zero_violation_dbg;    // alguma saída desabilitada diferente de zero?
  reg [N-1:0] zero_violation_mask_dbg;   // por saída

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

  // Modelo de referência (igual ao plano de verificação)
  integer j, a, b;
  always @* begin
    // expected_out[j] = enable ? in_data[route[j]] : 0
    expected_out_flat   = {N*W{1'b0}};
    expected_collision  = 1'b0;

    for (j = 0; j < N; j = j + 1) begin
      if (output_enable_tb[j])
        `EXP(j) = in_data_tb[`ROUTE(j)*W +: W];
      else
        `EXP(j) = {W{1'b0}};
    end

    // expected_collision
    for (a = 0; a < N; a = a + 1) begin
      for (b = a + 1; b < N; b = b + 1) begin
        if (output_enable_tb[a] && output_enable_tb[b] && (`ROUTE(a) == `ROUTE(b)))
          expected_collision = 1'b1;
      end
    end
  end

  // Debug visual para waves (quem está pedindo qual entrada)
  integer ii, jj;
  integer cnt;
  always @* begin
    any_zero_violation_dbg  = 1'b0;
    zero_violation_mask_dbg = {N{1'b0}};
    collision_on_input_dbg  = {N{1'b0}};

    for (ii = 0; ii < N; ii = ii + 1) begin
      requesters_per_input_dbg[ii] = {N{1'b0}};
      cnt = 0;

      for (jj = 0; jj < N; jj = jj + 1) begin
        requesters_per_input_dbg[ii][jj] = output_enable_tb[jj] && (`ROUTE(jj) == ii[ROUTE_BITS-1:0]);
        if (requesters_per_input_dbg[ii][jj])
          cnt = cnt + 1;
      end

      collision_on_input_dbg[ii] = (cnt >= 2);
    end

    for (jj = 0; jj < N; jj = jj + 1) begin
      if (!output_enable_tb[jj] && (`OUT(jj) !== {W{1'b0}})) begin
        zero_violation_mask_dbg[jj] = 1'b1;
        any_zero_violation_dbg = 1'b1;
      end
    end
  end

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  task print_vec_state;
    input [8*160-1:0] title;
    integer k;
    begin
      $display("\n================ %s ================", title);

      $write("route_tb         = [");
      for (k = 0; k < N; k = k + 1) begin
        if (k != N-1) $write("%0d, ", `ROUTE(k));
        else          $write("%0d", `ROUTE(k));
      end
      $write("]\n");

      $write("output_enable_tb = [");
      for (k = 0; k < N; k = k + 1) begin
        if (k != N-1) $write("%0d, ", output_enable_tb[k]);
        else          $write("%0d", output_enable_tb[k]);
      end
      $write("]\n");

      $write("in_data_tb       = [");
      for (k = 0; k < N; k = k + 1) begin
        if (k != N-1) $write("%02h, ", `IN(k));
        else          $write("%02h", `IN(k));
      end
      $write("]\n");

      $write("out_data_dut     = [");
      for (k = 0; k < N; k = k + 1) begin
        if (k != N-1) $write("%02h, ", `OUT(k));
        else          $write("%02h", `OUT(k));
      end
      $write("]\n");

      $write("expected_out     = [");
      for (k = 0; k < N; k = k + 1) begin
        if (k != N-1) $write("%02h, ", `EXP(k));
        else          $write("%02h", `EXP(k));
      end
      $write("]\n");

      $display("collision_error_dut = %0d | expected_collision = %0d",
               collision_error_dut, expected_collision);

      $display("collision_on_input_dbg = %b (bit i=1 => entrada i com 2+ requisitantes)",
               collision_on_input_dbg);
      $display("zero_violation_mask_dbg = %b", zero_violation_mask_dbg);
    end
  endtask

  task check_case;
    input [8*160-1:0] title;
    reg case_fail;
    integer k;
    begin
      checks = checks + 1;
      case_fail = 1'b0;

      // amostragem em posedge (estímulo foi aplicado antes, no negedge)
      @(posedge clk_tb);
      #1; // margem para delta-cycle / estabilidade combinacional

      print_vec_state(title);

      for (k = 0; k < N; k = k + 1) begin
        if (`OUT(k) !== `EXP(k)) begin
          $display("ERRO: out_data[%0d] = %02h, esperado = %02h", k, `OUT(k), `EXP(k));
          case_fail = 1'b1;
        end
      end

      if (collision_error_dut !== expected_collision) begin
        $display("ERRO: collision_error = %0d, esperado = %0d", collision_error_dut, expected_collision);
        case_fail = 1'b1;
      end

      if (case_fail) begin
        fails = fails + 1;
        $display("RESULTADO: FAIL");
      end else begin
        $display("RESULTADO: PASS");
      end
    end
  endtask

  // ---------------------------------------------------------------------------
  // Estímulos
  // ---------------------------------------------------------------------------
  integer k_init;

  initial begin
    checks = 0;
    fails  = 0;

    // Inicialização
    in_data_tb       = {N*W{1'b0}};
    route_tb         = {N*ROUTE_BITS{1'b0}};
    output_enable_tb = {N{1'b0}};

    for (k_init = 0; k_init < N; k_init = k_init + 1) begin
      requesters_per_input_dbg[k_init] = {N{1'b0}};
    end

    // ---------------- Caso A — 4 rotas simultâneas (sem colisão) ----------------
    @(negedge clk_tb);
    `ROUTE(0)=3; `ROUTE(1)=6; `ROUTE(2)=1; `ROUTE(3)=7;
    `ROUTE(4)=2; `ROUTE(5)=5; `ROUTE(6)=0; `ROUTE(7)=4;

    output_enable_tb[0]=1; output_enable_tb[1]=1; output_enable_tb[2]=1; output_enable_tb[3]=1;
    output_enable_tb[4]=0; output_enable_tb[5]=0; output_enable_tb[6]=0; output_enable_tb[7]=0;

    `IN(0)=8'h10; `IN(1)=8'h21; `IN(2)=8'h32; `IN(3)=8'h43;
    `IN(4)=8'h54; `IN(5)=8'h65; `IN(6)=8'h76; `IN(7)=8'h87;

    check_case("Caso A: 4 rotas simultaneas (sem colisao)");

    // ---------------- Caso B — colisão forçada ----------------
    @(negedge clk_tb);
    `ROUTE(0)=2; `ROUTE(1)=6; `ROUTE(2)=1; `ROUTE(3)=2;
    `ROUTE(4)=0; `ROUTE(5)=5; `ROUTE(6)=7; `ROUTE(7)=4;

    output_enable_tb[0]=1; output_enable_tb[1]=0; output_enable_tb[2]=0; output_enable_tb[3]=1;
    output_enable_tb[4]=0; output_enable_tb[5]=0; output_enable_tb[6]=0; output_enable_tb[7]=0;

    `IN(0)=8'h10; `IN(1)=8'h21; `IN(2)=8'h32; `IN(3)=8'h43;
    `IN(4)=8'h54; `IN(5)=8'h65; `IN(6)=8'h76; `IN(7)=8'h87;

    check_case("Caso B: Colisao forcada (saidas 0 e 3 -> entrada 2)");

    // ---------------- Caso C — enable/zero + colisão mascarada ----------------
    @(negedge clk_tb);
    `ROUTE(0)=5; `ROUTE(1)=6; `ROUTE(2)=1; `ROUTE(3)=7;
    `ROUTE(4)=5; `ROUTE(5)=0; `ROUTE(6)=2; `ROUTE(7)=3;

    output_enable_tb[0]=1; output_enable_tb[1]=1; output_enable_tb[2]=1; output_enable_tb[3]=1;
    output_enable_tb[4]=0; output_enable_tb[5]=0; output_enable_tb[6]=0; output_enable_tb[7]=0;

    `IN(0)=8'h10; `IN(1)=8'h21; `IN(2)=8'h32; `IN(3)=8'h43;
    `IN(4)=8'h54; `IN(5)=8'h65; `IN(6)=8'h76; `IN(7)=8'h87;

    check_case("Caso C.T0: Enable/zero + colisao mascarada (route[0]=route[4]=5, mas en[4]=0)");

    @(negedge clk_tb);
    `ROUTE(0)=5; `ROUTE(1)=6; `ROUTE(2)=1; `ROUTE(3)=7;
    `ROUTE(4)=7; `ROUTE(5)=0; `ROUTE(6)=2; `ROUTE(7)=3;

    output_enable_tb[0]=1; output_enable_tb[1]=1; output_enable_tb[2]=1; output_enable_tb[3]=1;
    output_enable_tb[4]=0; output_enable_tb[5]=0; output_enable_tb[6]=0; output_enable_tb[7]=0;

    `IN(0)=8'hA0; `IN(1)=8'hB1; `IN(2)=8'hC2; `IN(3)=8'hD3;
    `IN(4)=8'hE4; `IN(5)=8'hF5; `IN(6)=8'h16; `IN(7)=8'h27;

    check_case("Caso C.T1: Enable/zero prevalece mesmo com mudanca de rota e dados");

    // ---------------- Caso D — rota dinâmica (uma saída habilitada) ----------------
    @(negedge clk_tb);
    `ROUTE(0)=0; `ROUTE(1)=6; `ROUTE(2)=0; `ROUTE(3)=0;
    `ROUTE(4)=0; `ROUTE(5)=0; `ROUTE(6)=0; `ROUTE(7)=0;

    output_enable_tb = {N{1'b0}};
    output_enable_tb[1] = 1'b1;

    `IN(0)=8'h10; `IN(1)=8'h21; `IN(2)=8'h32; `IN(3)=8'h43;
    `IN(4)=8'h54; `IN(5)=8'h65; `IN(6)=8'h76; `IN(7)=8'h87;

    check_case("Caso D.T0: rota dinamica (saida 1 -> entrada 6)");

    @(negedge clk_tb);
    `ROUTE(1)=7;
    `IN(0)=8'h90; `IN(1)=8'h91; `IN(2)=8'h92; `IN(3)=8'h93;
    `IN(4)=8'h94; `IN(5)=8'h95; `IN(6)=8'h11; `IN(7)=8'h22;

    check_case("Caso D.T1: rota dinamica (saida 1 -> entrada 7)");

    @(negedge clk_tb);
    `ROUTE(1)=0;
    `IN(0)=8'h33; `IN(1)=8'h44; `IN(2)=8'h55; `IN(3)=8'h66;
    `IN(4)=8'h77; `IN(5)=8'h88; `IN(6)=8'h99; `IN(7)=8'hAA;

    check_case("Caso D.T2: rota dinamica (saida 1 -> entrada 0)");

    // ---------------- Caso extra — dinâmica + colisão variando no tempo ----------------
    @(negedge clk_tb);
    route_tb         = {N*ROUTE_BITS{1'b0}};
    output_enable_tb = {N{1'b0}};

    `ROUTE(0)=1; `ROUTE(3)=3;
    output_enable_tb[0]=1; output_enable_tb[3]=1;

    `IN(0)=8'h10; `IN(1)=8'h21; `IN(2)=8'h32; `IN(3)=8'h43;
    `IN(4)=8'h54; `IN(5)=8'h65; `IN(6)=8'h76; `IN(7)=8'h87;

    check_case("Extra.T0: sem colisao (0->1, 3->3)");

    @(negedge clk_tb);
    `ROUTE(0)=2; `ROUTE(3)=2;
    `IN(0)=8'h90; `IN(1)=8'h91; `IN(2)=8'h92; `IN(3)=8'h93;
    `IN(4)=8'h94; `IN(5)=8'h95; `IN(6)=8'h96; `IN(7)=8'h97;

    check_case("Extra.T1: com colisao (0->2, 3->2)");

    @(negedge clk_tb);
    `ROUTE(0)=4; `ROUTE(3)=4;
    output_enable_tb[3]=0;

    `IN(0)=8'hA0; `IN(1)=8'hA1; `IN(2)=8'hA2; `IN(3)=8'hA3;
    `IN(4)=8'hA4; `IN(5)=8'hA5; `IN(6)=8'hA6; `IN(7)=8'hA7;

    check_case("Extra.T2: colisao mascarada por disable");

    // Resumo final
    $display("\n====================================================");
    $display("Resumo tb_crossbar_system_top: checks=%0d fails=%0d", checks, fails);
    if (fails == 0) $display("FIM: tb_crossbar_system_top passou");
    else            $display("FIM: tb_crossbar_system_top falhou");
    $display("====================================================");

    $finish;
  end

endmodule
