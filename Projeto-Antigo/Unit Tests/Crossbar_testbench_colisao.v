`timescale 1ns/1ps

module tb_crossbar_switch;

    parameter N = 8;
    parameter W = 8;

    reg clk;
    reg  [N-1:0] [W-1:0] in;
    reg  [N-1:0] [$clog2(N)-1:0] input_sel;
    reg  [N-1:0] output_enable;

    wire [N-1:0] [W-1:0] out;
    wire collision_error;

    crossbar_switch #(
        .N(N),
        .W(W)
    ) dut (
        .clk(clk),
        .in(in),
        .input_sel(input_sel),
        .output_enable(output_enable),
        .out(out),
        .collision_error(collision_error)
    );

    // CLOCK
    always #5 clk = ~clk;

    initial begin

        clk = 0;

        // ATRIBUINDO VALORES
        in[0] = 8'hA1;
        in[1] = 8'hB2;
        in[2] = 8'hC3;
        in[3] = 8'hD4;
        in[4] = 8'h11;
        in[5] = 8'h22;
        in[6] = 8'h33;
        in[7] = 8'h44;

        // TESTE 1 (SEM COLISÃO)
        output_enable = 8'b11111111;

        input_sel[0] = 0;
        input_sel[1] = 1;
        input_sel[2] = 2;
        input_sel[3] = 3;
        input_sel[4] = 4;
        input_sel[5] = 5;
        input_sel[6] = 6;
        input_sel[7] = 7;

        #10;

        // TESTE 2 (COM COLISÃO)
        input_sel[0] = 0;
        input_sel[1] = 3;
        input_sel[2] = 2;
        input_sel[3] = 5;
        input_sel[4] = 3; 
        input_sel[5] = 6;
        input_sel[6] = 7;
        input_sel[7] = 1;

        #10;

        // TESTE 3 (DESATIVANDO UMA SAÍDA)

        output_enable = 8'b11101111;

        input_sel[1] = 3;
        input_sel[4] = 3;

        #10;

        // TESTE 4 (ROTAÇÃO)

        output_enable = 8'b11111111;

        input_sel[0] = 7;
        input_sel[1] = 6;
        input_sel[2] = 5;
        input_sel[3] = 4;
        input_sel[4] = 3;
        input_sel[5] = 2;
        input_sel[6] = 1;
        input_sel[7] = 0;

        #10;

        $stop;

    end

endmodule