`ifndef ENV_SV
`define ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../agents/agent.sv"
`include "../scoreboard/scoreboard.sv" 
`include "../coverage/coverage.sv"

class aes_env extends uvm_env;
    `uvm_component_utils(aes_env)
    
    aes_agent      aes_agt;
    aes_scoreboard scoreboard;
    aes_coverage   aes_cvg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        aes_agt = aes_agent::type_id::create("aes_agt", this);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "aes_agt", "is_active", UVM_ACTIVE);

        scoreboard = aes_scoreboard::type_id::create("scoreboard", this);
        aes_cvg = aes_coverage::type_id::create("aes_cvg", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        aes_agt.monitor.ap.connect(scoreboard.ap_imp);
        aes_agt.monitor.ap.connect(aes_cvg.analysis_export);
    endfunction
endclass : aes_env

`endif
