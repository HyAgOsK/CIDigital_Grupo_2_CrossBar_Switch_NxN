`timescale 1ns/1ps
module tb_crossbar_sem_checker;

  parameter N = 8;
  parameter W = 8;

  reg  [N*W-1:0] in_data_flat;
  reg  [N*N-1:0] select_SE_flat;
  reg  [N-1:0]   output_enable;
  wire [N*W-1:0] out_data_flat;

  // DUT
  crossbar_nxn #(.N(N), .W(W)) dut (
    .in_data_flat(in_data_flat),
    .select_SE_flat(select_SE_flat),
    .output_enable(output_enable),
    .out_data_flat(out_data_flat)
  );

  // =========================================================
  // SINAIS PARA WAVE (só o necessário)
  // =========================================================
  wire [W-1:0] in0  = in_data_flat[0*W +: W];
  wire [W-1:0] in1  = in_data_flat[1*W +: W];
  wire [W-1:0] in2  = in_data_flat[2*W +: W];
  wire [W-1:0] in3  = in_data_flat[3*W +: W];

  wire [W-1:0] out0 = out_data_flat[0*W +: W];
  wire [W-1:0] out1 = out_data_flat[1*W +: W];
  wire [W-1:0] out2 = out_data_flat[2*W +: W];
  wire [W-1:0] out3 = out_data_flat[3*W +: W];

  wire [N-1:0] sel0 = select_SE_flat[0*N +: N];
  wire [N-1:0] sel1 = select_SE_flat[1*N +: N];
  wire [N-1:0] sel2 = select_SE_flat[2*N +: N];
  wire [N-1:0] sel3 = select_SE_flat[3*N +: N];

  // =========================================================
  // HELPERS SIMPLES
  // =========================================================
  task set_in_fixed;
    begin
      // valores fáceis de enxergar
      in_data_flat = {N*W{1'b0}};
      in_data_flat[0*W +: W] = 8'hA0;
      in_data_flat[1*W +: W] = 8'hB1;
      in_data_flat[2*W +: W] = 8'hC2;
      in_data_flat[3*W +: W] = 8'hD3;
    end
  endtask

  task clear_all;
    begin
      in_data_flat   = {N*W{1'b0}};
      select_SE_flat = {N*N{1'b0}};
      output_enable  = {N{1'b0}};
    end
  endtask

  task show_min;
    input [8*32:1] tag;
    begin
      $display("---- %s ----", tag);
      $display("en[3:0]=%b  sel0=%b sel1=%b sel2=%b sel3=%b",
               output_enable[3:0], sel0, sel1, sel2, sel3);
      $display("in0=%h in1=%h in2=%h in3=%h | out0=%h out1=%h out2=%h out3=%h",
               in0,in1,in2,in3, out0,out1,out2,out3);
    end
  endtask

  initial begin
    // opcional: gera VCD (se usar Icarus/GTKWave)
    // $dumpfile("tb_crossbar_sem_checker.vcd");
    // $dumpvars(0, tb_crossbar_sem_checker);

    clear_all();
    #5;

    // =====================================================
    // 1) ENABLE=0 => tudo 0 (mesmo com dados e seleção)
    // =====================================================
    set_in_fixed();
    select_SE_flat[0*N +: N] = (1<<0); // out0<-in0 (mas enable=0)
    select_SE_flat[1*N +: N] = (1<<1); // out1<-in1
    select_SE_flat[2*N +: N] = (1<<2); // out2<-in2
    select_SE_flat[3*N +: N] = (1<<3); // out3<-in3
    output_enable = 8'b0000_0000;
    #5;
    show_min("1) enable=0 => saidas zeradas");
    #10;

    // =====================================================
    // 2) ONE-HOT (funcionamento normal)
    // out0<-in0, out1<-in1, out2<-in2, out3<-in3
    // =====================================================
    output_enable = 8'b0000_1111;
    #5;
    show_min("2) one-hot normal");
    #10;

    // =====================================================
    // 3) DISABLE de uma saída: desliga out2
    // =====================================================
    output_enable[2] = 1'b0;
    #5;
    show_min("3) disable out2 => out2=0");
    #10;

    // =====================================================
    // 4) MULTI-HOT em out0 (caso especial)
    // Como o módulo não usa OR, ele pega a ULTIMA entrada ativa no for
    // sel0 = in0 e in1 ativos => out0 tende a virar in1 (índice maior)
    // =====================================================
    output_enable = 8'b0000_1111;
    output_enable[2] = 1'b1; // volta out2
    select_SE_flat[0*N +: N] = ((1<<0) | (1<<1)); // multi-hot
    #5;
    show_min("4) multi-hot em out0 (visualizar comportamento)");
    #10;

    $display("FIM");
    $finish;
  end

endmodule
