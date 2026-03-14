module decriptography_controller(
    output reg [127:0] word,
    output reg         done,
    input  [127:0]     chave,
    input  [127:0]     cipher,
    input              start,
    input              rst,
    input              clk
);
	reg [2:0] currentState, nextState;
	parameter IDLE                = 3'b000;
	parameter LOAD_KEYS           = 3'b001;
	parameter INIT_ADDROUNDKEY    = 3'b010;
	parameter INVSHIFTROWS  = 3'b011;
	parameter INVSUBBYTES   = 3'b100;
	parameter ADDROUNDKEY   = 3'b101;
	parameter INVMIXCOL     = 3'b110;
	parameter FINISHED            = 3'b111;

	wire [127:0] auxInputState;
	wire [127:0] auxInputKey;
	wire [127:0] outputStateAddRoundKey;
	wire [127:0] outputStateInvSubBytes;
	wire [127:0] outputStateInvShiftRows;
	wire [127:0] outputStateInvMixColumns;

	reg [4:0] counter;

	wire [1407:0] expandedKeysFlat;  // 11x128 bits
	reg  [127:0] expandedKeys [0:10]; // 11 keys, 128 bits each

	reg [127:0] inputState, inputKey;

	assign auxInputState = inputState;
	assign auxInputKey  = inputKey;

	expansion_key       ek(expandedKeysFlat,         auxInputKey);
	add_round_key       rk(outputStateAddRoundKey,   auxInputState, auxInputKey);
	sub_bytes_inverse   sb(outputStateInvSubBytes,   auxInputState);
	shift_rows_inverse  sf(outputStateInvShiftRows,  auxInputState);
	mix_columns_inverse mc(outputStateInvMixColumns, auxInputState);

	always @(posedge clk, posedge rst)
	begin
		if(rst)
		begin
			currentState <= IDLE;
		end
		else
		begin
			currentState <= nextState;
		end
	end

	always @(currentState, start)
	begin
		case (currentState)
			IDLE:
			begin
				inputState = 128'd0;
				inputKey = 128'd0;
				done = 1'b0;
				word = 128'd0;
				counter = 4'd0;
				
				if(start)
				begin
					nextState = LOAD_KEYS;
				end
			end
			LOAD_KEYS:
			begin
				inputKey = chave;
				inputState = 128'd0;
				done = 1'b0;
				word = 128'd0;
				counter = 4'd10;
				nextState = INIT_ADDROUNDKEY;
			end
			INIT_ADDROUNDKEY:
			begin
				expandedKeys[10] = expandedKeysFlat[1407:1280];
				expandedKeys[9]  = expandedKeysFlat[1279:1152];
				expandedKeys[8]  = expandedKeysFlat[1151:1024];
				expandedKeys[7]  = expandedKeysFlat[1023:896];
				expandedKeys[6]  = expandedKeysFlat[895:768];
				expandedKeys[5]  = expandedKeysFlat[767:640];
				expandedKeys[4]  = expandedKeysFlat[639:512];
				expandedKeys[3]  = expandedKeysFlat[511:384];
				expandedKeys[2]  = expandedKeysFlat[383:256];
				expandedKeys[1]  = expandedKeysFlat[255:128];
				expandedKeys[0]  = expandedKeysFlat[127:0];

				inputState = cipher;
				inputKey = expandedKeys[10];
				nextState = INVSHIFTROWS;
			end
			INVSHIFTROWS:
			begin
				if(counter == 4'd10)
                begin
					inputState = outputStateAddRoundKey;
			    end
                else
                begin
                	inputState = outputStateInvMixColumns;
                end
				counter = counter - 1;
				nextState = INVSUBBYTES;
            end
            INVSUBBYTES:
			begin
				inputState = outputStateInvShiftRows;
				nextState = ADDROUNDKEY;
			end
			ADDROUNDKEY:
			begin
				inputKey = expandedKeys[counter];
				inputState = outputStateInvSubBytes;

                if(counter > 4'd0)
				begin
					nextState = INVMIXCOL;
				end
				else
				begin
					nextState = FINISHED;
				end	

			end
			INVMIXCOL:
			begin
				inputState = outputStateAddRoundKey;
				nextState = INVSHIFTROWS;
			end
			FINISHED:
			begin
				word = outputStateAddRoundKey;
				done = 1'b1;
				nextState = IDLE;
			end
			default:
			begin
				nextState = IDLE;
			end
		endcase
	end
endmodule


