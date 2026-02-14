module controller_decripto (
    output [127:0] palavra,
    output done,
    input  [127:0] chave,
    input  [127:0] cifra,
    input start,
    input rst,
    input clk
);

	reg [127:0] auxPalavra;
	assign palavra = auxPalavra;

	reg auxDone;
	assign done = auxDone;

	reg [2:0] currentState, nextState;

	parameter IDLE                = 3'b000;
	parameter LOAD_KEYS           = 3'b001;
	parameter INIT_ADDROUNDKEY    = 3'b010;
	parameter ROUND_INVSHIFTROWS  = 3'b011;
	parameter ROUND_INVSUBBYTES   = 3'b100;
	parameter ROUND_ADDROUNDKEY   = 3'b101;
	parameter ROUND_INVMIXCOL     = 3'b110;
	parameter FINISHED            = 3'b111;

	reg [4:0] contador;

	wire [1407:0] chavesExpandidasFlat;  // 11x128 bits da chave
	reg  [127:0] chavesExpandidas [0:10]; // 11 grupos de chaves de 128 bits cada

	reg [127:0] estadoEntrada, chaveEntrada;

	assign auxEstadoEntrada = estadoEntrada;
	assign auxChaveEntrada = chaveEntrada;

	expansion_key       ek(auxChaveEntrada, chavesExpandidasFlat);

	add_round_key       rk(auxEstadoEntrada, auxChaveEntrada, estadoSaidaAddRoundKey);
	sub_bytes_inverse   sb (auxEstadoEntrada, estadoSaidaInvSubBytes);
	shift_rows_inverse  sf (auxEstadoEntrada, estadoSaidaInvShiftRows);
	mix_columns_inverse mc(auxEstadoEntrada, estadoSaidaInvMixColumns);

	always @(posedge clk, posedge rst, posedge start)
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
				estadoEntrada = 128'd0;
				chaveEntrada = 128'd0;
				auxDone = 1'b0;
				auxPalavra = 128'd0;
				contador = 4'd0;
				
				if(start)
				begin
					nextState = LOAD_KEYS;
				end
			end
			LOAD_KEYS:
			begin
				chaveEntrada = chave;	
				estadoEntrada = 128'd0;
				auxDone = 1'b0;
				auxPalavra = 128'd0;
				contador = 4'd10;
				nextState = INIT_ADDROUNDKEY;	
			end
			INIT_ADDROUNDKEY:
			begin
				chavesExpandidas[10] = chavesExpandidasFlat[1407:1280];
				chavesExpandidas[9]  = chavesExpandidasFlat[1279:1152];
				chavesExpandidas[8]  = chavesExpandidasFlat[1151:1024];
				chavesExpandidas[7]  = chavesExpandidasFlat[1023:896];
				chavesExpandidas[6]  = chavesExpandidasFlat[895:768];
				chavesExpandidas[5]  = chavesExpandidasFlat[767:640];
				chavesExpandidas[4]  = chavesExpandidasFlat[639:512];
				chavesExpandidas[3]  = chavesExpandidasFlat[511:384];
				chavesExpandidas[2]  = chavesExpandidasFlat[383:256];
				chavesExpandidas[1]  = chavesExpandidasFlat[255:128];
				chavesExpandidas[0]  = chavesExpandidasFlat[127:0];

				estadoEntrada = cifra;
				chaveEntrada = chavesExpandidas[10];
				nextState = ROUND_INVSHIFTROWS;
			end
			ROUND_INVSHIFTROWS: 
			begin
				if(contador == 4'd10)
                begin				
					estadoEntrada = estadoSaidaAddRoundKey;
			    end
                else
                begin 
                	estadoEntrada = estadoSaidaInvMixColumns;
                end
				contador = contador - 1;				
				nextState = ROUND_INVSUBBYTES;
            end
            ROUND_INVSUBBYTES:
			begin
				estadoEntrada = estadoSaidaInvShiftRows;
				nextState = ROUND_ADDROUNDKEY;
			end
			ROUND_ADDROUNDKEY:
			begin
				chaveEntrada = chavesExpandidas[contador];
				estadoEntrada = estadoSaidaInvSubBytes;

                if(contador > 4'd0)
				begin
					nextState = ROUND_INVMIXCOL;
				end
				else
				begin					
					nextState = FINISHED;
				end	

			end
			ROUND_INVMIXCOL:
			begin
				estadoEntrada = estadoSaidaAddRoundKey;
				nextState = ROUND_INVSHIFTROWS;
			end
			FINISHED:
			begin
				auxPalavra = estadoSaidaAddRoundKey;
				auxDone = 1'b1;
				nextState = IDLE;
			end
			default:
			begin
				nextState = IDLE;
			end
		endcase
	end
endmodule


