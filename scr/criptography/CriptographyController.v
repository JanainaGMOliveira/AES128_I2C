module criptography_controller(
	output reg [127:0] cipher,
	output reg         done,
	input      [127:0] key,
	input      [127:0] word,
	input              start,
	input              rst,
	input              clk
);
	reg [2:0] currentState, nextState;
    parameter IDLE = 3'b000;
	parameter LOAD_KEYS = 3'b001;
	parameter INIT_ADDROUNDKEY = 3'b010;
	parameter SUBBYTES = 3'b011;
	parameter SHIFTROWS = 3'b100;
	parameter MIXCOL = 3'b101;
	parameter ADDROUNDKEY = 3'b110,;
	parameter FINISHED = 3'b111;
	
	wire [127:0] auxInputState;
	wire [127:0] auxInputKey;
	wire [127:0] outputStateAddRoundKey;
	wire [127:0] outputStateSubBytes;
	wire [127:0] outputStateShiftRows;
	wire [127:0] outputStateMixColumns;

	reg [4:0] counter;

	wire [1407:0] expandedKeysFlat;  // 11x128 bits da key
	reg [127:0]   expandedKeys [0:10]; // 11  keys, 128 bits each

	reg [127:0] inputState, inputKey;

	assign auxInputState = inputState;
	assign auxInputKey   = inputKey;

	expansion_key ek(expandedKeysFlat,       auxInputKey);
	add_round_key rk(outputStateAddRoundKey, auxInputState, auxInputKey);
	sub_bytes     sb(outputStateSubBytes,    auxInputState);
	shift_rows    sr(outputStateShiftRows,   auxInputState);
	mix_columns   mc(outputStateMixColumns,  auxInputState);

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
				cipher = 128'd0;
				counter = 4'd0;
				
				if(start)
				begin
					nextState = LOAD_KEYS;
				end
			end
			LOAD_KEYS: // Expansion Key
			begin
				inputKey = key;
				inputState = 128'd0;
				done = 1'b0;
				cipher = 128'd0;
				counter = 4'd0;
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

				inputState = word;
				inputKey = expandedKeys[0];
				counter = 4'd0;
				nextState = SUBBYTES;
			end
			SUBBYTES:
			begin
				counter = counter + 1;
				inputState = outputStateAddRoundKey;
				nextState = SHIFTROWS;
			end
			SHIFTROWS:
			begin
				inputState = outputStateSubBytes;
				if(counter == 4'd10)
				begin
					nextState = ADDROUNDKEY;
				end
				else
				begin
					nextState = MIXCOL;
				end
			end
			MIXCOL:
			begin
				inputState = outputStateShiftRows;
				nextState = ADDROUNDKEY;
			end
			ADDROUNDKEY:
			begin
				inputKey = expandedKeys[counter];

				if(counter == 4'd10)
				begin
					inputState = outputStateShiftRows;
					nextState = FINISHED;
				end
				else
				begin
					inputState = outputStateMixColumns;
					nextState = SUBBYTES;
				end
			end
			FINISHED:
			begin
				cipher = outputStateAddRoundKey;
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