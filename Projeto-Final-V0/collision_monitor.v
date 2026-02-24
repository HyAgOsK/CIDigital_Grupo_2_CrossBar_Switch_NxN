module collision_monitor #(
  parameter N = 8,
  parameter ROUTE_BITS = clog2(N)
)(
  input  [N*ROUTE_BITS-1:0] route_flat,   // Rotas de todas as saídas (flatten)
  input  [N-1:0]            output_enable,// Máscara de habilitação por saída
  output reg                collision_error // Flag global de colisão
);

  // Índices de comparação entre pares de saídas
  integer a, b;

  // Registradores temporários para armazenar route[a] e route[b]
  reg [ROUTE_BITS-1:0] route_a, route_b;

  always @* begin
    // Valor padrão: sem colisão
    collision_error = 1'b0;

    // Compara todos os pares únicos de saídas (a,b) com b>a
    // Complexidade O(N^2), aceitável para N pequeno/moderado neste projeto
    for (a = 0; a < N; a = a + 1) begin
      for (b = a + 1; b < N; b = b + 1) begin
        // Extrai as rotas atuais de a e b
        route_a = route_flat[a*ROUTE_BITS +: ROUTE_BITS];
        route_b = route_flat[b*ROUTE_BITS +: ROUTE_BITS];

        // Há colisão se:
        // 1) as duas saídas estão habilitadas
        // 2) ambas selecionam a mesma entrada
        if (output_enable[a] && output_enable[b] && (route_a == route_b))
          collision_error = 1'b1;
      end
    end
  end

endmodule
