module crossbar_nxn #(
  parameter int N = 8,          // N = 2^k
  parameter int W = 8
) (
  input  logic [W-1:0] in_data       [N],
  input  logic         select_SE     [N][N],
  input  logic         output_enable [N],
  output logic [W-1:0] out_data      [N]
);

    //TODO
    // Desenvolva o código aqui
endmodule
