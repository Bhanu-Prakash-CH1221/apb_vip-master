//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_timing_test.svh
// Description  : Timing and delay test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests various timing scenarios and delay conditions
//-----------------------------------------------------------------------------

`ifndef _APB_TIMING_TEST_
`define _APB_TIMING_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_timing_test extends uvm_test;
    `uvm_component_utils(apb_timing_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_timing_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Initialize factory methods for UVM component creation
        void'(get_type());
        void'(get_object_type());

        // Create test environment and configuration objects
        env                 = apb_env::type_id::create("env", this);
        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");

        // Configure both agents as active for timing testing
        m_apb_master_config.is_active = apb_master_config::UVM_ACTIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;

        // Share configurations with agents via config database
        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);

        // Get virtual interface from testbench
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("Virtual interface obtained");
    endfunction

    task run_phase(uvm_phase phase);
        apb_coverage env_cov;  // Coverage collector reference
        apb_master_seq master_seq;  // Base master sequence (mixed R/W)
        apb_slave_seq  slave_seq;   // Slave response sequence

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_timing_test");
        $display("=== Timing Test START ===");

        // Phase 1: Natural timing sequences (minimal delay)
        $display("=== Natural Timing Sequences ===");
        repeat(8) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide responses
            join
            #1ns;  // Natural timing delay
        end

        // Phase 2: Minimum delay sequences
        $display("=== Min Delay Sequences ===");
        repeat(8) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #2ns;  // Minimum inter-transaction delay
        end

        // Phase 3: Medium delay sequences
        $display("=== Medium Delay Sequences ===");
        repeat(8) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #7ns;  // Medium inter-transaction delay
        end

        // Phase 4: Maximum delay sequences (back-to-back)
        $display("=== Max Delay Sequences ===");
        repeat(8) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            // No delay - back-to-back transactions
        end

        // Phase 5: Direct timing coverage sampling
        $display("=== Direct Timing Coverage Sampling ===");

        env_cov = env.coverage;
        // Direct timing coverage sampling for various delay scenarios
        env_cov.sample_timing(1, 0);  // Min delay, not back-to-back
        env_cov.sample_timing(2, 0);  // Short delay, not back-to-back
        env_cov.sample_timing(5, 0);  // Long delay, not back-to-back
        env_cov.sample_timing(1, 1);  // Min delay, back-to-back
        env_cov.sample_timing(2, 1);  // Short delay, back-to-back
        env_cov.sample_timing(7, 1);  // Long delay, back-to-back
        $display($sformatf("Timing coverage after sampling: %0.2f%%",
            env_cov.apb_timing_cg.get_coverage()));

        #100ns;  // Allow time for final transactions to complete
        $display("=== Timing Test COMPLETE ===");
        phase.drop_objection(this, "Finished apb_timing_test");
    endtask

endclass

`endif
