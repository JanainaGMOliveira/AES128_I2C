`ifndef COVERAGE_SV
`define COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_coverage extends uvm_subscriber #(aes_transaction);
    `uvm_component_utils(aes_coverage)

    covergroup aes_cg;
        option.per_instance = 1;
        // command_cp : coverpoint current_command {
        //     bins all_cmds[] = { SEND_DATA_TO_GPIO,
        //                         SEND_DATA_TO_SPI,
        //                         SEND_DATA_TO_I2C,
        //                         SEND_DATA_TO_UART
        //                     };
        // }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        aes_cg = new();
    endfunction
    
    function void write(aes_transaction t);
        aes_cg.sample();
        `uvm_info("AES COVERAGE", $sformatf("Sampled Data: 0x%h", t.word), UVM_HIGH)
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("AES COVERAGE", $sformatf("--- COVERAGE REPORT ---\n Data Coverage: %f%%\n", aes_cg.get_coverage()), UVM_LOW)
    endfunction

endclass : aes_coverage
`endif