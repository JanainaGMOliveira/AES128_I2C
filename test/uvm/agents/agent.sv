`ifndef AGENT_SV
`define AGENT_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"

class aes_agent extends uvm_agent;
    `uvm_component_utils(aes_agent)
    
    aes_sequencer sequencer;
    aes_driver    driver;
    aes_monitor   monitor;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);

        if (is_active == UVM_ACTIVE)
        begin
            sequencer = aes_sequencer::type_id::create("sequencer", this);
            driver    = aes_driver::type_id::create("driver", this);
        end
        else
        begin
            `uvm_info("AES AGENT", "Building PASSIVE AES AGENT: Only Monitor included.", UVM_HIGH)
        end

        monitor = aes_monitor::type_id::create("monitor", this);

        if (!uvm_config_db#(virtual aes_bfm)::get(this, "", "bfm", monitor.bfm))
        begin
            `uvm_fatal("AES AGENT", "Virtual interface 'bfm' not set for Monitor. Check environment build.")
        end

        if (is_active == UVM_ACTIVE)
        begin
            if (!uvm_config_db#(virtual aes_bfm)::get(this, "", "bfm", driver.bfm))
            begin
                `uvm_fatal("AES AGENT", "Virtual interface 'bfm' not set for Driver. Check environment build.")
            end
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (is_active == UVM_ACTIVE)
        begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction : connect_phase

endclass : aes_agent
`endif