`ifndef BFM_SV
`define BFM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

interface aes_bfm;
    bit clk;
    bit reset;

    // Inputs
    bit [127:0] word;
    bit [127:0] key;
    bit operation;

    // Outputs
    bit [127:0] cipher;
    bit         done;

    // task to generate clock signal
    task generate_clock(input real period = 20, bit clk_pol = 0, real delay = 0);
        clk = ~clk_pol;
        #(delay);

        forever
		begin
            clk = ~clk;
            #(period/2);
        end

    endtask : generate_clock

    // task to generate reset pulse
    task reset_pulse(input bit rst_pol = '0, int rst_width = 2, string rst_type = "Sync", bit rst_edge = 1);
      	if (rst_type == "Sync")
		begin
        	if (rst_edge)
            	@(posedge clk);
         	else
            	@(negedge clk);
      	end
      	reset = rst_pol;

        if (rst_type == "Async")
        begin 
            #(rst_width);
        end
        else
        begin
            repeat (rst_width)
            begin
                if (rst_edge)
                    @(posedge clk);
                else
                    @(negedge clk);
            end
        end
        reset = ~rst_pol;
        
    endtask : reset_pulse

endinterface

`endif