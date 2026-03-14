module top_i2c_aes128(
    output reg [127:0] cipher,
    output reg         done,
    inout sda,
    input scl,
    input clock,
    input reset
);
    reg [1:0] currentState;
    parameter RESET_STATE = 2'b00;
    parameter CALCULATION_STATE = 2'b01;
    parameter RESULT_STATE = 2'b10;

    wire [127:0] word, key, outCripto, outDecripto;
    
    wire operation; // 0: cripto, 1: decripto
    wire startI2C;
    wire doneI2C, doneCripto, doneDecripto;

    reg enableCripto, enableDecripto;

    wire [263:0] auxI2Cout;
    assign word = auxI2Cout[263:136];
    assign key = auxI2Cout[135:8];
    assign operation = auxI2Cout[0];

    i2c_slave                 i2c(auxI2Cout, ,startI2C, doneI2C, clock, reset, scl, sda);
    criptography_controller   cripto(outCripto, doneCripto, key, word, enableCripto, reset, clock);
    decriptography_controller decripto(outDecripto, doneDecripto, key, word, enableDecripto, reset, clock);

    always @(posedge clock, posedge reset)
	begin
        if(reset)
		begin
			currentState <= RESET_STATE;
		end
		else
        begin
            case (currentState)
                RESET_STATE:
                begin
                    enableCripto = 1'b0;
                    enableDecripto = 1'b0;
                    done = 1'b0;
                    
                    if(doneI2C)
                    begin
                        enableCripto = !operation;
                        enableDecripto = operation;
                        currentState = CALCULATION_STATE;
                    end
                end
                CALCULATION_STATE:
                begin
                    if(enableCripto && doneCripto)
                    begin
                        enableCripto = 1'b0;
                        cipher = outCripto;
                        currentState = RESULT_STATE;
                    end
                    else if (enableDecripto && doneDecripto) 
                    begin
                        enableDecripto = 1'b0;
                        cipher = outDecripto;
                        currentState = RESULT_STATE;
                    end
                    else
                    begin
                        currentState = CALCULATION_STATE;
                    end
                end
                RESULT_STATE:
                begin
                    done = 1'b1;

                    if(!startI2C)
                    begin
                        currentState = RESET_STATE;
                    end
                    else
                    begin
                        currentState = CALCULATION_STATE;
                    end
                end
            endcase
        end
    end
endmodule