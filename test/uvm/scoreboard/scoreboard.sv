`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../transaction.sv" 
`include "../aes_macros.svh" 

class aes_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(aes_scoreboard)
    
    uvm_analysis_imp #(aes_transaction, aes_scoreboard) ap_request_imp;
    uvm_tlm_analysis_fifo #(aes_transaction) ap_response_imp;

    int aes_transaction_count = 0;
    int errors;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        ap_request_imp    = new("ap_request_imp", this);
        ap_response_imp   = new("ap_response_imp", this);
    endfunction : new

    function void write(aes_transaction item);
        // bit [GPIO_DATA_BITS-1:0] expected_data;

        // if (expected_data == item.data)
        // begin
        //     gpio_transaction_count++;
        //     gpio_transaction_correct++;
        // end
        // else if (actual_cmd != 8'h0)
        // begin
        //     gpio_transaction_count++;
        //     gpio_transaction_wrong++;
        //     errors++;
        //     `uvm_info("SCOREBOARD", $sformatf("Expected GPIO: 0x%h | Received GPIO: 0x%h", expected_data, item.data), UVM_MEDIUM);
        // end
    endfunction

    task run_phase(uvm_phase phase);
        // uart_transaction uart_item;

        // int count = 0;

        // forever
        // begin
        //     uart_ap_rx_imp.get(uart_item);
        //     get_msg_uart(uart_item);

        //     // TODO: REFACTOR TO GET INITIAL MESSAGE OR OTHER MESSAGES AT SAME TIME
            
        //         // Receiving initial message
        //          count++;

        //         if (count >= INITIAL_MSG.len())
        //         begin
        //             if (INITIAL_MSG !=  msg_received_uart)
        //             begin
        //                 errors++;
        //                 uart_transaction_wrong++;
        //                 uart_transaction_rx_count++;
        //                 `uvm_info("SCOREBOARD", $sformatf("Expected UART: %s | Received UART: %s", INITIAL_MSG, msg_received_uart), UVM_MEDIUM);
        //             end
        //             else
        //             begin
        //                 uart_transaction_correct++;
        //                 uart_transaction_rx_count++;
        //             end
        //             initial_msg = msg_received_uart;
        //             msg_received_uart = "";
        //             first_msg = 0;
        //             count = 0;
        //         end
            
        // end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("SCOREBOARD", "===================== Scoreboard Report ====================", UVM_LOW)
        // `uvm_info("SCOREBOARD", $sformatf("UART write on DUT:               %0d transactions ", uart_transaction_tx_count), UVM_LOW)
        // `uvm_info("SCOREBOARD", $sformatf("UART read from DUT:              %0d transactions ", uart_transaction_rx_count), UVM_LOW)
        // `uvm_info("SCOREBOARD", $sformatf("UART message correctly received: %0d              ", uart_transaction_correct), UVM_LOW)
        // `uvm_info("SCOREBOARD", $sformatf("UART message wrongly received:   %0d              ", uart_transaction_wrong), UVM_LOW)
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


