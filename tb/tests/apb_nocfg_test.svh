`ifndef _APB_NOCFG_TEST_
`define _APB_NOCFG_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

// apb_nocfg_test:
//   Deliberately does NOT call uvm_config_db::set for either config.
//   Forces both apb_master_agent and apb_slave_agent to take the
//   if(!uvm_config_db::get(...)) TRUE branch → uvm_warning + create default.
//   This branch is 0% hit by every other test.

class apb_nocfg_test extends uvm_test;
    `uvm_component_utils(apb_nocfg_test)

    apb_env        env;
    virtual apb_if vif;

    function new(string name = "apb_nocfg_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Intentionally NO config_db set for apb_master_config or apb_slave_config.
        // Both agents will print a WARNING and create default configs (UVM_ACTIVE).
        env = apb_env::type_id::create("env", this);
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("NOCFG_TEST: no configs set - expecting WARNING from both agents");
    endfunction

    task run_phase(uvm_phase phase);
        apb_master_seq master_seq;
        apb_slave_seq  slave_seq;

        super.run_phase(phase);
        phase.raise_objection(this, "apb_nocfg_test START");
        $display("=== NoCfg Test START ===");
        $display("NOCFG_TEST: Running sequences with default configs");
        #300ns;

        // Both agents are ACTIVE by default - run transactions
        repeat (3) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #5ns;
        end

        #50ns;
        $display("=== NoCfg Test COMPLETE ===");
        phase.drop_objection(this, "apb_nocfg_test DONE");
    endtask

endclass

`endif