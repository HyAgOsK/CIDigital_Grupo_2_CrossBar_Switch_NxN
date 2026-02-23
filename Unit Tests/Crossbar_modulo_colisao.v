
module crossbar_switch #(
    parameter N = 8,
    parameter W = 8
)(
    input wire clk,
    input wire [N-1:0] [W-1:0] in,                  // Portas de entrada
    input wire [N-1:0] [$clog2(N)-1:0] input_sel,   // Seletor
    input wire [N-1:0] output_enable,

    output wire [N-1:0] [W-1:0] out,                // Portas de saída
    output wire collision_error                     // Indicador de colisão
);

    wire [N-1:0] [W-1:0] shifter_out;
    wire [$clog2(N)-1:0] shift;                     // Quantidade de rotações
    wire mapping_error;

    crossbar_switch_mapping_monitor #(
        .N(N)
    ) monitor_inst (
        .input_sel(input_sel),
        .output_enable(output_enable),
        .shift(shift),
        .mapping_error(mapping_error),
        .collision_error(collision_error)
    );

    crossbar_switch_barrel_shifter #(
        .N(N),
        .W(W)
    ) barrel_inst (
        .in(in),
        .shift(shift),
        .out(shifter_out)
    );

    // Ativação das saídas
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: OUTPUT_LOGIC
            assign out[i] =
                (output_enable[i] && !collision_error)
                ? shifter_out[i]
                : {W{1'b0}};
        end
    endgenerate

endmodule

module crossbar_switch_barrel_shifter #(
    parameter N = 8,
    parameter W = 8
)(
    input wire [N-1:0] [W-1:0] in,
    input wire [$clog2(N)-1:0] shift,
    output wire [N-1:0] [W-1:0] out
);

    wire [2*N-1:0] [W-1:0] in_double;
    assign in_double = {in, in};

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin: MUX
            assign out[k] = in_double[k + shift];
        end
    endgenerate

endmodule

module crossbar_switch_mapping_monitor #(
    parameter N = 8
)(
    input  wire [N-1:0] [$clog2(N)-1:0] input_sel,
    input  wire [N-1:0] output_enable,

    output wire [$clog2(N)-1:0] shift,
    output wire mapping_error,                      // Sem importância até o momento
    output wire collision_error
);

    assign shift = input_sel[0];

    reg collision;

    integer i, j;

    //Detectando colisões
    always @(*) begin
        collision = 1'b0;

        for (i = 0; i < N; i = i + 1) begin
            for (j = i+1; j < N; j = j + 1) begin
                if (
                    output_enable[i] &&
                    output_enable[j] &&
                    (input_sel[i] == input_sel[j])
                ) begin
                    collision = 1'b1;
                end
            end
        end
    end

    assign collision_error = collision;
    assign mapping_error   = 1'b0;

endmodule