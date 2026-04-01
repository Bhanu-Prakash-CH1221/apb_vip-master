//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_basic_test.svh
// Description  : Basic functionality test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests basic read/write operations with various timing scenarios
//-----------------------------------------------------------------------------

`ifndef _APB_BASIC_TEST_
`define _APB_BASIC_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_basic_test extends uvm_test;
    `uvm_component_utils(apb_basic_test)

    // Test components
    apb_env              env;                 // APB verification environment
    apb_master_config    m_apb_master_config; // Master agent configuration
    apb_slave_config     m_apb_slave_config;  // Slave agent configuration
    virtual apb_if        vif;                 // Virtual interface to DUT

    apb_master_seq       master_seq;          // Base master sequence (mixed R/W)
    apb_slave_seq        slave_seq;           // Slave response sequence

    function new(string name = "apb_basic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Initialize factory methods for UVM component creation
        void'(get_type());
        void'(get_object_type());

        // Create configuration objects
        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");

        // Configure both agents as active for basic functionality testing
        m_apb_master_config.is_active = apb_master_config::UVM_ACTIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;

        // Share configurations with agents via config database
        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);

        // Create test environment
        env = apb_env::type_id::create("env", this);

        // Get virtual interface from testbench
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("Virtual interface obtained");
    endfunction

    task run_phase(uvm_phase phase);
        apb_master_seq master_seq;  // Base master sequence (mixed R/W)
        apb_slave_seq  slave_seq;   // Slave response sequence

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_basic_test");

        // Phase 1: Basic transactions with minimal delay
        $display("Phase 1: MIN_DELAY (delay=1)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive mixed R/W transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide slave responses
            join
            #1ns;  // Minimal inter-transaction delay
        end

        // Phase 2: Transactions with short delay
        $display("Phase 2: MAX_DELAY (delay=2)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #2ns;  // Short inter-transaction delay
        end

        // Phase 3: Transactions with long delay
        $display("Phase 3: LONG_DELAY (delay=3-10)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #7ns;  // Long inter-transaction delay
        end

        // Phase 4: Back-to-back transactions (consecutive)
        $display("Phase 4: Back-to-back (CONSECUTIVE)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            // No delay - consecutive transactions
        end

        // Phase 5: Randomized timing scenarios
        $display("Phase 5: Mixed timing");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            void'(master_seq.randomize());
            void'(slave_seq.randomize());
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #($urandom_range(0, 5));  // Random delay between 0-5ns
        end

        phase.drop_objection(this, "Finished apb_basic_test");
    endtask

endclass

`endif
