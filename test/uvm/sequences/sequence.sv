`ifndef SEQUENCES_SV
`define SEQUENCES_SV

`include "../aes_macros.svh"
`include "../transaction.sv"

class aes_random_seq extends uvm_sequence #(aes_transaction);
    `uvm_object_utils(aes_random_seq)

    int unsigned max_transactions = MAX_TRANSACTIONS;

    function new(string name = "aes_random_seq");
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

            assert(item.randomize());
            `uvm_info("AES SEQUENCE", $sformatf("Sending AES key: 0x%h, word: 0x%h, operation: %s", item.key, item.word, item.operation == 1 ? "DECRIPTO" : "CRIPTO"), UVM_MEDIUM)

            finish_item(item);
        end

        if (starting_phase != null)
        begin
            starting_phase.drop_objection(this);
        end
    endtask

endclass : aes_random_seq

class aes_corner_seq extends uvm_sequence #(aes_transaction);
    `uvm_object_utils(aes_corner_seq)

    int unsigned max_transactions = MAX_TRANSACTIONS;

    function new(string name = "aes_corner_seq");
        super.new(name);
    endfunction

    task body();
        
        if (starting_phase != null)
        begin
            starting_phase.raise_objection(this);
        end

        send(128'h0,    128'h0,    1);
        send(128'h0,    128'h0,    0);
        send('1,        '1,        1);
        send('1,        '1,        0);
        send(128'hAAAA, 128'hAAAA, 1);
        send(128'hAAAA, 128'hAAAA, 0);
        send(128'h0,    128'h0,    1);
        send(128'h0,    '1,        1);
        send(128'h0,    '1,        0);
        send('1,        128'h0,    1);
        send('1,        128'h0,    0);

        if (starting_phase != null)
        begin
            starting_phase.drop_objection(this);
        end
    endtask

    task send(logic [127:0] w, logic [127:0] k, logic op);
        aes_transaction item = aes_transaction::type_id::create("item");

        start_item(item);

        item.word      = w;
        item.key       = k;
        item.operation = op;

        finish_item(item);
    endtask
endclass : aes_corner_seq
`endif