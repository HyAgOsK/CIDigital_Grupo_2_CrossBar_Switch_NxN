module barrel_shifter #(
  parameter N = 8,
  parameter ROUTE_BITS = clog2(N)
)(
  input  [N*ROUTE_BITS-1:0] route_flat,      // Vetor flatten com route[j] para cada saída j
  output [N*N-1:0]          select_SE_flat   // Matriz flatten de seleção: linha j ocupa [j*N +: N]
);

  // j percorre as saídas (cada saída possui uma rota independente)
  genvar j;
  generate
    for (j = 0; j < N; j = j + 1) begin : GEN_ROW
      // route_j = índice da entrada selecionada pela saída j
      wire [ROUTE_BITS-1:0] route_j;

      // onehot_j = vetor one-hot de tamanho N:
      // bit i = 1 indica que a entrada i deve conectar à saída j
      wire [N-1:0] onehot_j;

      // Extrai route[j] do vetor flatten
      assign route_j = route_flat[j*ROUTE_BITS +: ROUTE_BITS];

      // Decodificação binário -> one-hot
      // Se route_j for válido (< N), ativa exatamente um bit.
      // Se for inválido (>= N), gera tudo zero (proteção contra rota fora de faixa).
      assign onehot_j = (route_j < N) ?
                        ({{(N-1){1'b0}},1'b1} << route_j) :
                        {N{1'b0}};

      // Escreve a linha j da matriz de seleção (select_SE[j][*]) no vetor flatten
      assign select_SE_flat[j*N +: N] = onehot_j;
    end
  endgenerate

endmodule
