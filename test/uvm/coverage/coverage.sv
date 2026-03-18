`ifndef COVERAGE_SV
`define COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_coverage extends uvm_subscriber #(aes_transaction);
    `uvm_component_utils(aes_coverage)

    aes_transaction item;

    covergroup aes_cg;
        cp_operation: coverpoint item.operation {
            bins encrypt = {0};
            bins decrypt = {1};
        }

        cp_word: coverpoint item.word {
            bins zero        = {128'h0};
            bins all_ones    = {128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF};
            bins alternating = {128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA};
            bins random      = default;
        }

        cp_key: coverpoint item.key {
            bins zero        = {128'h0};
            bins all_ones    = {128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF};
            bins alternating = {128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA};
            bins random      = default;
        }

        cp_cipher: coverpoint item.cipher {
            bins zero     = {128'h0};
            bins non_zero = default;
        }

        cp_op_transition: coverpoint item.operation {
            bins enc_to_enc = (1 => 1);
            bins dec_to_dec = (0 => 0);
            bins enc_to_dec = (1 => 0);
            bins dec_to_enc = (0 => 1);
        }

        cx_op_word: cross cp_operation, cp_word;

        cx_op_key: cross cp_operation, cp_key;

        // cx_word_key: cross cp_word, cp_key {
        //     bins word_eq_key_zero = binsof(cp_word.zero) && binsof(cp_key.zero);
        //     bins word_eq_key_ones = binsof(cp_word.all_ones) && binsof(cp_key.all_ones);
        //     bins word_eq_key_alt  = binsof(cp_word.alternating) && binsof(cp_key.alternating);
        //     bins zero_word_max_key = binsof(cp_word.zero) && binsof(cp_key.all_ones);
        //     bins max_word_zero_key = binsof(cp_word.all_ones) && binsof(cp_key.zero);

        //     ignore_bins uninteresting = binsof(cp_word.random) && binsof(cp_key.random);
        // }

        cx_zero_check: cross cp_cipher, cp_word, cp_key
        {
            bins legit_zero = binsof(cp_cipher.zero) 
                        && binsof(cp_word.zero) 
                        && binsof(cp_key.zero);
            
            // bins suspicious = binsof(cp_cipher.zero) 
            //             && binsof(cp_word.random);
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        aes_cg = new();
    endfunction
    
    function void write(aes_transaction t);
        item = t;
        aes_cg.sample();
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("AES COVERAGE", $sformatf("--- COVERAGE REPORT ---\n Data Coverage: %f%%\n", aes_cg.get_coverage()), UVM_LOW)
    endfunction

endclass : aes_coverage
`endif