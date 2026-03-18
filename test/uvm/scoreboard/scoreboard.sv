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
    
    bit [AES_DATA_BITS-1:0] wordInputCripto;
    bit [AES_DATA_BITS-1:0] cipherOutputCripto;
    bit [AES_DATA_BITS-1:0] wordOutputDecripto;
    bit [AES_DATA_BITS-1:0] cipherInputDecripto;
    bit [AES_DATA_BITS-1:0] keyCripto;
    bit [AES_DATA_BITS-1:0] keyDecripto;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        ap_imp    = new("ap_imp", this);
    endfunction : new

    function void write(aes_transaction item);
        aes_transaction_count++;
        
        if (item.operation == 1)
        begin
            keyDecripto = item.key;
            cipherInputDecripto = item.word;
            wordOutputDecripto = item.cipher;
            aes_decripto_count++;
        end
        else
        begin
            keyCripto = item.key;
            wordInputCripto = item.word;
            cipherOutputCripto = item.cipher;
            aes_cripto_count++;
        end

        if (item.cipher === 128'h0 && item.word !== 128'h0)
            `uvm_error("SCOREBOARD", $sformatf("Cipher is zero to word=%h key=%h op=%0b", item.word, item.key, item.operation))

        check_values();
    endfunction

    function check_values();
        if (aes_decripto_count == aes_cripto_count && aes_transaction_count != 0)
        begin
            if (keyCripto == keyDecripto && cipherOutputCripto == cipherInputDecripto) // the cripto output is the decripto input
            begin
                if (wordInputCripto != wordOutputDecripto)
                begin
                    errors++;
                    `uvm_info("SCOREBOARD", $sformatf("Input cripto: %h | Output decripto: %h", wordInputCripto, wordOutputDecripto), UVM_MEDIUM);
                end
            end
        end
    endfunction

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


