`timescale 1ns/10ps
import aes_pkg::*;
`include "aes_pkg.sv"
`include "tests/aes_test.sv"
`include "aes_macros.svh"

module uvm_tb_top;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   import aes_pkg::*;
   
    aes_bfm  bfm();

    top_i2c_aes128 DUT(
        .cipher   (bfm.cipher),
        .done     (bfm.done),
        .word     (bfm.word),
        .key      (bfm.key),
        .operation(bfm.operation),
        .clock    (bfm.clk),
        .reset    (bfm.reset)
    );

    initial
    begin
        `uvm_info("TOP", "TOP UVM", UVM_MEDIUM)
        uvm_config_db #(virtual aes_bfm)::set(null, "*", "bfm", bfm);

        $dumpfile("uvm_tb_top.vcd");
        $dumpvars(0, uvm_tb_top);

        run_test();
    end

    initial
    begin
        fork
            bfm.generate_clock(CLK_PERIOD);
            bfm.reset_pulse(1, 5, "Sync", 1);
        join_none
    end
    
endmodule : uvm_tb_top
