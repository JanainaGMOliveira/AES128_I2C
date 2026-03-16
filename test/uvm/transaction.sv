`ifndef TRANSACTIONS_SV
`define TRANSACTIONS_SV

import uvm_pkg::*;    
    `include "uvm_macros.svh"

`include "aes_macros.svh"

class aes_transaction extends uvm_sequence_item;
    rand bit [AES_DATA_BITS-1:0] word;
    rand bit [AES_DATA_BITS-1:0] key;
    rand bit                     operation;
    bit      [AES_DATA_BITS-1:0] cipher; // data after cripto
    bit      [AES_DATA_BITS-1:0] decripto; // data after decripto - must be equal word
    
    `uvm_object_utils_begin(aes_transaction)
        `uvm_field_int(word, UVM_ALL_ON)
        `uvm_field_int(key, UVM_ALL_ON)
        `uvm_field_int(operation, UVM_ALL_ON)
        `uvm_field_int(cipher, UVM_ALL_ON)
        `uvm_field_int(decripto, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "aes_transaction");
        super.new(name);
    endfunction
endclass : aes_transaction

`endif