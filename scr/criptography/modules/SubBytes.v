module sub_bytes(
	output [127:0] out,
	input [127:0] in
);
	genvar i;
	generate 
		for(i=0; i<128; i=i+8) 
		begin
			sbox s(out[i +:8], in[i +:8]); // create one and call it n times
		end
	endgenerate
endmodule