module BarrelShifterWords #(
    parameter N = 8,                  // Número de "portas" (quantas words existem no barramento)
    parameter W = 8,                  // Largura de cada word (em bits)
    parameter SHIFT_W = $clog2(N)     // Largura do sinal de shift (bits necessários para contar 0..N-1)
)(
    input  [N*W-1:0] in_bus,          // Barramento de entrada "achatado": N words de W bits
                                      // Convenção: word k ocupa in_bus[k*W +: W]

    input  [SHIFT_W-1:0] shift,       // Quantidade de rotação (em unidades de word)

    output [N*W-1:0] out_bus          // Barramento de saída "achatado": N words de W bits
);

    genvar k;                         // Variável usada apenas em generate (tempo de elaboração)

    generate
        // Cria N atribuições contínuas, uma para cada word de saída
        for (k = 0; k < N; k = k + 1) begin : G_ROT

            // out_bus[k] recebe in_bus[(k + shift) % N]
            // - k*W +: W seleciona a word k da saída
            // - ((k + shift) % N)*W +: W seleciona a word de entrada correspondente
            //
            // Isso implementa rotação circular por words:
            // shift=0 -> saída igual entrada
            // shift=1 -> out[0]=in[1], out[1]=in[2], ..., out[N-1]=in[0]
            assign out_bus[k*W +: W] = in_bus[((k + shift) % N)*W +: W];
        end
    endgenerate

endmodule
