`timescale 1ns / 1ps

module crossbar_switch_tb;
	localparam N = 8; // Quantidade de portas de entrada do switch
	localparam W = 8; // Tamanho do barramento de cada porta do switch

    reg clk;                                 // Clock
    reg [N-1:0] [W-1:0] in;                  // Portas de entrada do switch
	reg [N-1:0] [$clog2(N)-1:0] input_sel;   // Seletores de portas de entrada (a ser utilizado pelas portas de saída)
	reg [N-1:0] output_enable;               // Ativadores das portas de saída do switch
	wire [N-1:0] [W-1:0] out;                // Portas de saída do switch
	wire mapping_error;                      // Sinal de erro de mapeamento (mapeamento de portas não permitido pelo Barrel Shifter)
	wire collision_error;                    // Sinal de erro de colisão (duas ou mais saídas escolheram a mesma entrada)

	// Instância do módulo top-level
    crossbar_switch #(
		.N(N),
		.W(W)
	) cs1 (
		.clk(clk),
		.in(in),
		.input_sel(input_sel),
		.output_enable(output_enable),
		.out(out),
		.mapping_error(mapping_error),
		.collision_error(collision_error)
    );

	// Sinais que serão monitorados no console (a cada mudança de valor, é exibido no console da simulação)
	initial begin
		$monitor("Tempo: %08t | in=%p, input_sel=%p, output_enable=%b | out=%p, mapping_error=%b, collision_error=%b",
				$time, in, input_sel, output_enable, out, mapping_error, collision_error);
	end

	// Inicialização do clock
	initial begin
		clk = 1'b0;
		forever begin
			#1 clk = ~clk;
		end
	end

	// Geração dos sinais de entrada
	initial begin
		// TODO

		// SUGESTÃO: sinais de entrada osciladores seguindo a seguinte lógica:
		//   * Porta 0: 1 período = +2 períodos de clock
		//   * Porta 1: 1 período = -2 períodos de clock (defasagem de 180 graus em relação ao sinal anterior)
		//
		//   * Porta 2: 1 período = +3 períodos de clock
		//   * Porta 3: 1 período = -3 períodos de clock (defasagem de 180 graus em relação ao sinal anterior)
		//
		//   * ...
	end

	// CASOS DE TESTE
	initial begin
		$display("\nTESTE - MAPEAMENTO TOTAL 1 (TODAS AS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS) COM ZERAGEM PARCIAL APOS UM TEMPO");
		// TODO (Atenção! Deve haver zeragem assíncrona "output_enable" de algumas saídas após um tempo)

		$display("\nTESTE - MAPEAMENTO TOTAL 2 (TODAS AS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS), SEGUIDA POR MAPEAMENTO TOTAL 3, SEGUIDA POR ZERAGEM TOTAL");
		// TODO (Atenção! Mapeamento total 2, seguida por mapeamento total 3, seguida por zeragem assíncrona de todas as saídas)

		$display("\nTESTE - MAPEAMENTO PARCIAL 1 (ALGUMAS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS)");
		// TODO

		$display("\nTESTE - MAPEAMENTO TOTAL INVALIDO 1 (TODAS AS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS, MAS COMBINACAO NAO SUPORTADA PELO BARREL SHIFTER)");
		// TODO

		$display("\nTESTE - MAPEAMENTO PARCIAL 2 (ALGUMAS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS)");
		// TODO

		$display("\nTESTE - MAPEAMENTO TOTAL INVALIDO 2 (TODAS AS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS, MAS COMBINACAO NAO SUPORTADA PELO BARREL SHIFTER)");
		// TODO

		$display("\nTESTE - MAPEAMENTO TOTAL 4 (TODAS AS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS)");
		// TODO

		$display("\nTESTE - MAPEAMENTO PARCIAL INVALIDO (ALGUMAS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS, MAS COMBINACAO NAO SUPORTADA PELO BARREL SHIFTER)");
		// TODO

		$display("\nTESTE - MAPEAMENTO TOTAL 5 (TODAS AS PORTAS DE ENTRADAS MAPEADAS PARA SAIDAS)");
		// TODO

		$display("\nTESTE - MAPEAMENTO COM COLISAO (A MESMA PORTA DE ENTRADA MAPEADA PARA MULTIPLAS SAIDAS)");
		// TODO

		$finish; // Finalizar a simulação
	end

	// // DEPURAÇÃO (UTILIZAR PARA TESTES, CASO NECESSÁRIO)
	// // Exemplo de uso:
	// always @(VAR1, VAR2) begin
	// 	// COMANDO PARA DEPURAÇÃO (APARECE NO TERMINAL). SÓ PODE SER USADO EM BLOCOS PROCESSUAIS.
	// 	// Utilizar nos módulos, caso necessário
	// 	$display("Debugging >> Variavel1=%b, Variavel2=%b", VAR1, VAR2);
	// end

endmodule
