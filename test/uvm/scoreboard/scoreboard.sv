`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../transaction.sv" 
`include "../aes_macros.svh" 

class aes_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(aes_scoreboard)
    
    uvm_analysis_imp #(aes_transaction, aes_scoreboard) ap_imp;

    int aes_transaction_count = 0;
    int aes_cripto_count = 0;
    int aes_decripto_count = 0;
    int errors;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        ap_imp    = new("ap_imp", this);
    endfunction : new

    function void write(aes_transaction item);
        aes_transaction_count++;
        `uvm_info("AES SCOREBOARD", "Received item", UVM_HIGH);
        // compare the results for cripto and decripto
        if (item.operation == 1)
        begin
            aes_decripto_count++;
        end
        else
        begin
            aes_cripto_count++;
        end
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info("AES SCOREBOARD", "End run_fase", UVM_HIGH);
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("SCOREBOARD", "===================== Scoreboard Report ====================", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("AES criptography:   %0d", aes_cripto_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("AES decriptography: %0d", aes_decripto_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("AES operations:     %0d", aes_transaction_count), UVM_LOW)
        `uvm_info("SCOREBOARD", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Errors:                          %0d              ", errors), UVM_LOW)
        `uvm_info("SCOREBOARD", "============================================================", UVM_LOW)
        
        if(errors > 0)
            `uvm_error("SCOREBOARD", "TEST FAILED: Scoreboard reported mismatches.")
        else
            `uvm_info("SCOREBOARD", "Test completed with NO errors!", UVM_LOW)
    endfunction
endclass
`endif


