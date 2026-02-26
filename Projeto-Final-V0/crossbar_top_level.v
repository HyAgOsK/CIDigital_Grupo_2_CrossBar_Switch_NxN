module crossbar_top_level #(
  parameter N = 8,
  parameter W = 8,
  parameter ROUTE_BITS = $clog2(N)
)(
  input  [N*W-1:0]          in_data_flat,     // Dados de entrada (flatten)
  input  [N*ROUTE_BITS-1:0] route_flat,       // Rotas por saída (flatten)
  input  [N-1:0]            output_enable,    // Habilitação por saída
  output [N*W-1:0]          out_data_flat,    // Dados de saída (flatten)
  output                    collision_error    // Flag global de colisão
);

  // Sinal interno: matriz de seleção gerada a partir das rotas
  // Representa select_SE[j][i] em formato flatten.
  wire [N*N-1:0] select_SE_int_flat;

  // ---------------------------------------------------------------------------
  // Plano de Controle: converte route[j] em one-hot select_SE[j][i]
  // ---------------------------------------------------------------------------
  barrel_shifter #(
    .N(N),
    .ROUTE_BITS(ROUTE_BITS)
  ) u_barrel_shifter (
    .route_flat(route_flat),
    .select_SE_flat(select_SE_int_flat)
  );

  // ---------------------------------------------------------------------------
  // Datapath: realiza a comutação NxN + aplica enable/zero por saída
  // ---------------------------------------------------------------------------
  crossbar_nxn #(
    .N(N),
    .W(W)
  ) u_crossbar_nxn (
    .in_data_flat(in_data_flat),
    .select_SE_flat(select_SE_int_flat),
    .output_enable(output_enable),
    .out_data_flat(out_data_flat)
  );

  // ---------------------------------------------------------------------------
  // Monitoramento: detecta conflito de seleção entre saídas habilitadas
  // ---------------------------------------------------------------------------
  collision_monitor #(
    .N(N),
    .ROUTE_BITS(ROUTE_BITS)
  ) u_collision_monitor (
    .route_flat(route_flat),
    .output_enable(output_enable),
    .collision_error(collision_error)
  );

endmodule
