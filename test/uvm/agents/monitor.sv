`ifndef MONITOR_SV
`define MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_monitor extends uvm_monitor;
    `uvm_component_utils(aes_monitor)
    
    virtual aes_bfm bfm;
    uvm_analysis_port #(aes_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        ap = new("ap", this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual aes_bfm)::get(this, "", "bfm", bfm))
            `uvm_warning("UART_MON", "Virtual interface `bfm` not found via uvm_config_db. Check config_db::set path.")
    endfunction
    
    task run_phase(uvm_phase phase);
        monitor_aes();
    endtask

    task monitor_aes();
        aes_transaction transaction;

        forever
        begin
            @(posedge bfm.done)
            `uvm_info("AES MONITOR", "Received done", UVM_HIGH);

            transaction = aes_transaction::type_id::create("transaction");
            transaction.key       = bfm.key;
            transaction.word      = bfm.word;
            transaction.cipher    = bfm.cipher;
            transaction.operation = bfm.operation;

            ap.write(transaction);
        end
    endtask
endclass : aes_monitor
`endif 