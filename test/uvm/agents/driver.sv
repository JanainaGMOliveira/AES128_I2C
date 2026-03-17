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

        @(negedge bfm.reset);

        forever
        begin
            seq_item_port.get_next_item(item);

            send_command(item);

            seq_item_port.item_done();
        end
    endtask : run_phase

    task send_command(aes_transaction item);
        // Send the cripto command
        bfm.start     <= 1;
        bfm.word      <= item.word;
        bfm.key       <= item.key;
        bfm.operation <= item.operation;

        @(posedge bfm.clk)
        bfm.start     <= 0;

        // Wait done
        @(posedge bfm.done) // to not send any command before the previous end
        @(posedge bfm.clk)
        // Send inverse command
        bfm.start     <= 1;
        bfm.operation <= ~item.operation;
        bfm.word      <= bfm.cipher;

        @(posedge bfm.clk)
        bfm.start     <= 0;

        @(posedge bfm.done);
        @(posedge bfm.clk);
    endtask
endclass : aes_driver
`endif