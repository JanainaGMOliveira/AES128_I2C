`ifndef SEQUENCER_SV
`define SEQUENCER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../transaction.sv"

class aes_sequencer extends uvm_sequencer #(aes_transaction);
    `uvm_component_utils(aes_sequencer)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

endclass
`endif