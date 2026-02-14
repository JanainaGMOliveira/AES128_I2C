module sub_bytes(
	input [127:0] in,
	output [127:0] out
);
	genvar i;
	generate 
		for(i=0; i<128; i=i+8) 
		begin
			sbox s(out[i +:8], in[i +:8]);
		end
	endgenerate
endmodule