module barrel_shifter #(
  parameter N = 8,
  parameter ROUTE_BITS = $clog2(N)
)(
  input  [N*ROUTE_BITS-1:0] route_flat,      // Vetor flatten com route[j] para cada saída j
  output [N*N-1:0]          select_SE_flat   // Matriz flatten de seleção: linha j ocupa [j*N +: N]
);

  // vetor one hot entrada 0 selecionada
  localparam [N-1:0] BASE_ONEHOT = {{(N-1){1'b0}}, 1'b1};

  // j percorre as saídas (cada saída possui uma rota independente)
  genvar j;
  generate
    for (j = 0; j < N; j = j + 1) begin : GEN_ROW
      // route_j = índice da entrada selecionada pela saída j
      wire [ROUTE_BITS-1:0] route_j;
      // onehot_j = vetor one-hot de tamanho N:
      // bit i = 1 indica que a entrada i deve conectar à saída j
      wire [N-1:0] onehot_j;

      // Vetores para rotação barrel (circular)
      wire [2*N-1:0] base_dup_j;
      wire [2*N-1:0] shifted_j;

      // Extrai route[j] do vetor flatten
      assign route_j = route_flat[j*ROUTE_BITS +: ROUTE_BITS];

      // Duplica o vetor base para permitir rotação circular via shift
      assign base_dup_j = {BASE_ONEHOT, BASE_ONEHOT};

      // Realiza a rotação circular do vetor base
      assign shifted_j = base_dup_j << route_j;

      // Se route_j for válido (<N), pega os N bits menos significativos
      // isso equivale a um left rotate,
      // Se invalido (quando N não é potência de 2) zera linha
      assign onehot_j = (route_j < N) ? shifted_j[N-1:0]:{N{1'b0}};

      // Escreve a linha j da matriz de seleção (select_SE[j][*]) no vetor flatten
      assign select_SE_flat[j*N +: N] = onehot_j;
    end
  endgenerate

endmodule
