`ifndef SEQUENCES_SV
`define SEQUENCES_SV

`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_seq extends uvm_sequence #(aes_transaction);
    `uvm_object_utils(aes_seq)

    int unsigned max_transactions = MAX_TRANSACTIONS;

    function new(string name = "aes_seq");
        super.new(name);
    endfunction

    task body();
        aes_transaction item;
        
        if (starting_phase != null)
        begin
            starting_phase.raise_objection(this);
        end

        `uvm_info("AES SEQUENCE", $sformatf("Starting %0d random AES commands", max_transactions), UVM_LOW)

        repeat (max_transactions)
        begin
            item = aes_transaction::type_id::create("item");

            start_item(item);

            //assert(this.randomize());
            item.word = 128'h00112233445566778899aabbccddeeff;
            item.key = 128'h000102030405060708090a0b0c0d0e0f;
            item.operation = 0; // on this seuqence, I'll send always a cripto operation and will check the data after cripto and decripto
            `uvm_info("AES SEQUENCE", $sformatf("Sending AES key: 0x%h, word: 0x%h, operation: %s", item.key, item.word, item.operation == 1 ? "DECRIPTO" : "CRIPTO"), UVM_MEDIUM)

            finish_item(item);
        end

        if (starting_phase != null)
        begin
            starting_phase.drop_objection(this);
        end
    endtask

endclass : aes_seq
`endif