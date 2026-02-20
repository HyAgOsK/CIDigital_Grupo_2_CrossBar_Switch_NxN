module barrel_shifter #(
  parameter int N = 8,
  localparam int ROUTE_BITS = $clog2(N)
)(
  input  logic [ROUTE_BITS-1:0] route [N],   // route[j] = índice da entrada escolhida para saída j
  output logic [N-1:0] select_SE [N]    // select_SE[j][i] one-hot (linha j)
);

  genvar j;
  generate
    for (j = 0; j < N; j++) begin : GEN_ROW
      always_comb begin
        select_SE[j] = 0;                 // zera toda a linha (N bits)
        select_SE[j][route[j]] = 1'b1;     // ativa somente o bit da coluna route[j]
      end
    end
  endgenerate

endmodule
