`timescale 1ns/1ps 

module top_i2c_aes128_TB;

    wire clk;
    reg rst;

    wire done;
    wire [127:0] saida;

    reg [127:0] word, key;
    reg operation, start;

    clockGenerator #(10) clkGenerator(clk); // Gerador de clock geral 100Mhz (10ns)
    top_aes128 tb_top(saida, done, word, key, operation, start, clk, rst); //Instancia do Modulo TOP

    initial begin
        rst = 1;
        start = 0;
        #15 rst = 0;

        word = 128'h00112233445566778899aabbccddeeff;
        key = 128'h000102030405060708090a0b0c0d0e0f;
        operation = 0;
        start = 1;
        #20 start = 0;

        #5000
        word = 128'h3243f6a8885a308d313198a2e0370734;
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        start = 1;
        #20 start = 0;




        //Chamada para as tasks de teste com os valores (id, palavra, resultado ciphra)
        // executarTeste(0, 128'h00112233445566778899aabbccddeeff, 128'h000102030405060708090a0b0c0d0e0f, 128'h69c4e0d86a7b0430d8cdb78070b4c55a);
        // executarTeste(1, 128'h3243f6a8885a308d313198a2e0370734, 128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3925841d02dc09fbdc118597196a0b32);
        // executarTeste(2, 128'h00000000000000000000000000000000, 128'h00000000000000000000000000000000, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e);
        // executarTeste(3, 128'hffffffffffffffffffffffffffffffff, 128'h00000000000000000000000000000000, 128'h3f5b8cc9ea855a0afa7347d23e8d664e);
        // executarTeste(4, 128'haabbccddeeff00112233445566778899, 128'h102030405060708090a0b0c0d0e0f000, 128'h2be52b98821c28a467897944fa4ac1bc);

        #5000;
        $stop;
    end

    task executarTeste(input integer id, input [127:0] palavra, input [127:0] chave, input [127:0] ciphra);
        begin
            //-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-CRIPTOGRAFIA-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
            // Visualização dos resultados obtidos no display
            $display("\n Teste %0d  Criptografia AES-128", id);
            $display("Entrada  = %h", palavra); // Valor da entrada da Criptografia e Base de comparação para a Descriptografia
            $display("Chave    = %h", chave);
            $display("Esperado = %h", ciphra); // Valor de base de comparação na Criptografia e Entrada para a Descriptografia
            
            // Configuração dos dados e envio
            word = palavra;
            key = chave;
            operation = 0;
            
            //Aguarda o done da FSM
            wait(done);
            $display("Obtido   = %h", saida);
            
            //Comparação dos resultados obtidos na criptografia
            if (saida === ciphra)
                $display("Resultado CORRETO!");
            else
                $display(" Resultado INCORRETO!");
            
            // Reset e atraso antes do proximo teste
            rst = 1;
            #15 rst = 0;
            //-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-DESCRIPTOGRAFIA-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
            // Visualização dos valores no display
            $display("\n Teste %0d  Descriptografia AES-128", id);
            $display("Entrada  = %h", ciphra);
            $display("Chave    = %h", chave);
            $display("Esperado = %h", palavra);

            // Configuração dos dados e envio
            word = ciphra;
            key = chave;
            operation = 1;

            wait(done); #20
            $display("Obtido   = %h", saida);
            //Comparação dos resultados obtidos
            if (saida === palavra)
                $display("Resultado CORRETO!");
            else
                $display(" Resultado INCORRETO!");

            // rst = 1;
            // #15 rst = 0;
           // #3000;
        end
    endtask
endmodule

// Clock generator
module clockGenerator #(parameter period = 5)(
    output clk
);
    reg outClk = 0;
    always #(period/2) outClk = ~outClk;
    assign clk = outClk;
endmodule
