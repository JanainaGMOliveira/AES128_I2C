module add_round_key(
    output [127:0] state_out,
    input  [127:0] state_in,
    input  [127:0] round_key
);
    assign state_out = state_in ^ round_key;
endmodule
