// -----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_nocfg_test.svh
// Description  : Configuration-less test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests behavior without explicit configuration objects
// -----------------------------------------------------------------------------

`ifndef _APB_NOCFG_TEST_
`define _APB_NOCFG_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_nocfg_test extends uvm_test;
    `uvm_component_utils(apb_nocfg_test)

    // Test components (minimal - no explicit configuration objects)
    apb_env        env;                 // APB verification environment
    virtual apb_if vif;                 // Virtual interface to DUT

    function new(string name = "apb_nocfg_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase - creates environment without explicit configuration
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Initialize factory methods for UVM component creation
        void'(get_type());
        void'(get_object_type());

        // Create test environment (agents will use default configurations)
        env = apb_env::type_id::create("env", this);
        
        // Get virtual interface from testbench
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("NOCFG_TEST: no configs set - expecting WARNING from both agents");
    endfunction

    // Run phase - tests behavior with default configurations
    task run_phase(uvm_phase phase);
        apb_master_seq master_seq;  // Base master sequence (mixed R/W)
        apb_slave_seq  slave_seq;   // Slave response sequence

        super.run_phase(phase);
        phase.raise_objection(this, "apb_nocfg_test START");
        $display("=== NoCfg Test START ===");
        $display("NOCFG_TEST: Running sequences with default configs");
        #300ns;  // Allow system to stabilize

        repeat (3) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide responses
            join
            #5ns;  // Inter-transaction delay
        end

        #50ns;  // Allow time for final operations
        $display("=== NoCfg Test COMPLETE ===");
        phase.drop_objection(this, "apb_nocfg_test DONE");
    endtask

endclass

`endif