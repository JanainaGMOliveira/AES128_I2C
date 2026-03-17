module top_aes128(
    output reg [127:0] cipher,
    output reg         done,
    input [127:0] word, // for a initial test, will not use the i2c
    input [127:0] key,
    input operation,
    input start,
    input clock,
    input reset
);
    reg [1:0] currentState;
    parameter RESET_STATE = 2'b00;
    parameter CALCULATION_STATE = 2'b01;
    parameter RESULT_STATE = 2'b10;

    wire [127:0] outCripto, outDecripto;

    wire doneCripto, doneDecripto;

    reg enableCripto, enableDecripto;

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

                    if(start)
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

                    if(!start)
                    begin
                        currentState = RESET_STATE;
                    end
                    else
                    begin
                        done = 1'b0;
                        enableCripto = !operation;
                        enableDecripto = operation;
                        currentState = CALCULATION_STATE;
                    end
                end
            endcase
        end
    end
endmodule