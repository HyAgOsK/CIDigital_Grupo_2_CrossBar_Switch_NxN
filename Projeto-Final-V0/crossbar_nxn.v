module crossbar_nxn #(
  parameter N = 8,
  parameter W = 8
)(
  input  [N*W-1:0]     in_data_flat,     // Entradas flatten: in_data[i] ocupa [i*W +: W]
  input  [N*N-1:0]     select_SE_flat,   // Matriz de seleção flatten: linha j em [j*N +: N]
  input  [N-1:0]       output_enable,    // Habilitação por saída
  output reg [N-1:0]   collision_error,  // Erro de colisão de seleção
  output reg [N*W-1:0] out_data_flat     // Saídas flatten: out_data[j] ocupa [j*W +: W]
);

  integer i, j;

  // tmp_out acumula o dado selecionado para a saída j
  reg [W-1:0] tmp_out;

  // sel_row representa a linha j da matriz de seleção (one-hot idealmente)
  reg [N-1:0] sel_row;

  always @* begin
    // Inicializa todas as saídas com zero
    // Isso ajuda a garantir comportamento determinístico e simplifica lógica combinacional.
    out_data_flat = {N*W{1'b0}};

    // Para cada saída j...
    for (j = 0; j < N; j = j + 1) begin
      tmp_out = {W{1'b0}};
      sel_row = select_SE_flat[j*N +: N]; // select_SE[j][*]

      // Só comuta dados se a saída estiver habilitada
      if (output_enable[j]) begin
        // Percorre todas as entradas i
        for (i = 0; i < N; i = i + 1) begin
          // Se bit i da linha de seleção estiver ativo, encaminha in_data[i] para saída j
          // Uso de OR torna o módulo robusto caso haja multi-hot acidental em sel_row
          // (em condição ideal, sel_row é one-hot e apenas uma entrada contribui).
          if (sel_row[i])
            tmp_out = in_data_flat[i*W +: W];
        end
      end

      // Escreve a saída j no vetor flatten
      // Se output_enable[j]=0, permanece zero (precedência de disable)
      out_data_flat[j*W +: W] = tmp_out;
    end
  end

endmodule
