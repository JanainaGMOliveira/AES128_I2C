`ifndef MONITOR_SV
`define MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_monitor extends uvm_monitor;
    `uvm_component_utils(aes_monitor)
    
    virtual aes_bfm bfm;
    uvm_analysis_port #(aes_transaction) ap_response;
    uvm_analysis_port #(aes_transaction) ap_request;

    uvm_event ev_initial_msg_done;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        ap_response = new("ap_response", this);
        ap_request = new("ap_request", this);

        ev_initial_msg_done = uvm_event_pool::get_global("ev_initial_msg_done");
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual aes_bfm)::get(this, "", "bfm", bfm))
            `uvm_warning("UART_MON", "Virtual interface `bfm` not found via uvm_config_db. Check config_db::set path.")
    endfunction
    
    task run_phase(uvm_phase phase);
        aes_transaction transaction_rx, transaction_tx;
        // bit [UART_DATA_BITS-1:0] data_byte_rx, data_byte_tx;
        // bit erro_rx, erro_tx, timed_out;

        // // TODO: REFACTOR TO GET INITIAL MESSAGE OR OTHER MESSAGES AT SAME TIME

        // // Monitorar mensagem inicial
        // repeat(INITIAL_MSG.len())
        // begin
        //     monitor_aes(1'b1, data_byte_rx, erro_rx);  // DUT enviando para UART

        //     transaction_rx = aes_transaction::type_id::create("transaction_rx");
        //     transaction_rx.data = data_byte_rx;
        //     transaction_rx.framing_error = erro_tx;

        //     ap_rx.write(transaction_rx);
        // end

        // ev_initial_msg_done.trigger();
        
        // fork
        //     forever
        //     begin
        //         monitor_aes(1'b0, data_byte_tx, erro_tx); // UART enviando para DUT

        //         transaction_tx = aes_transaction::type_id::create("transaction_tx");
        //         transaction_tx.data = data_byte_tx;
        //         transaction_tx.framing_error = erro_tx;

        //         ap_tx.write(transaction_tx);
        //     end
        
        //     forever
        //     begin
        //         monitor_aes(1'b1, data_byte_rx, erro_rx); // DUT enviando para UART

        //         transaction_rx = aes_transaction::type_id::create("transaction_rx");
        //         transaction_rx.data = data_byte_rx;
        //         transaction_rx.framing_error = erro_rx;

        //         ap_rx.write(transaction_rx);
                
        //     end

        //     begin
        //         #(100ms);
        //         timed_out = 1;
        //         `uvm_error("UART MONITOR", "Timeout! UART não enviou nenhum comando em 100ms")
        //     end
        // join_any
        // disable fork;

        // if (timed_out) return;
    endtask

    task monitor_aes();
        aes_transaction transaction;

        forever
        begin
            @(bfm.key)

            transaction = aes_transaction::type_id::create("transaction");
            transaction.key = bfm.key;

            ap_request.write(transaction);
        end
    endtask
endclass : aes_monitor
`endif 