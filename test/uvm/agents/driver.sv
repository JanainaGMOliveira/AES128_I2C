`ifndef DRIVER_SV
`define DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_driver extends uvm_driver #(aes_transaction);
    `uvm_component_utils(aes_driver)

    virtual aes_bfm bfm;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual aes_bfm)::get(this, "", "bfm", bfm))
        begin
            `uvm_fatal("AES DRIVER", "Virtual interface 'bfm' not set.")
        end
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        aes_transaction item;

        forever
        begin
            seq_item_port.get_next_item(item);

            send_command(item);

            seq_item_port.item_done();
        end
    endtask : run_phase

    task send_command(aes_transaction item);
        // Send the cripto command
        bfm.word      = item.word;
        bfm.key       = item.key;
        bfm.operation = item.operation;

        // Wait done
        @(posedge bfm.done)
        @(posedge bfm.clk)
        item.cipher = bfm.cipher;

        // Send inverse command
        bfm.operation = ~item.operation;
        bfm.word      = bfm.cipher;
    endtask
endclass : aes_driver
`endif