module sub_bytes_inverse(
	output [127:0] out,
	input  [127:0] in
);
	genvar i;
	generate 
		for(i=0; i<128; i=i+8) 
		begin
			sbox_inverse s(out[i +:8], in[i +:8]); // not the best approach - try to create one and call it n times
		end
	endgenerate
endmodule