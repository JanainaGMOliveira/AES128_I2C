`ifndef TEST_SV
`define TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../env/environment.sv"
`include "../sequences/sequence.sv"

class aes_test extends uvm_test;
    `uvm_component_utils(aes_test)
    
    aes_env env;
    
    function new(string name = "aes_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        env = aes_env::type_id::create("env", this);
        `uvm_info("AES TEST", "End build_fase", UVM_HIGH);
    endfunction

    task run_phase(uvm_phase phase);
        aes_random_seq seq_random = aes_random_seq::type_id::create("seq_random");
        aes_corner_seq seq_corner = aes_corner_seq::type_id::create("seq_corner");

        phase.raise_objection(this);
        
        seq_random.start(env.aes_agt.sequencer);
        seq_corner.start(env.aes_agt.sequencer);

        phase.drop_objection(this);
    endtask
endclass : aes_test
`endif