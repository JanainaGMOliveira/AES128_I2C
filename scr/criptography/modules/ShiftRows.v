module shift_rows(
    output [127:0] state_out,
    input  [127:0] state_in
);
    assign state_out = {
        state_in[127:120], // s0
        state_in[87:80],   // s5
        state_in[47:40],   // s10
        state_in[7:0],     // s15

        state_in[95:88],   // s4
        state_in[55:48],   // s9
        state_in[15:8],    // s14
        state_in[103:96],  // s3

        state_in[63:56],   // s8
        state_in[23:16],   // s13
        state_in[111:104], // s2
        state_in[71:64],   // s7

        state_in[31:24],   // s12
        state_in[119:112], // s1
        state_in[79:72],   // s6
        state_in[39:32]    // s11
    };
endmodule

