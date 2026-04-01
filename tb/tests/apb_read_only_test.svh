//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_read_only_test.svh
// Description  : Read-only operations test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests read transactions with various timing scenarios
//-----------------------------------------------------------------------------

`ifndef _APB_READ_ONLY_TEST_
`define _APB_READ_ONLY_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_read_only_test extends uvm_test;
    `uvm_component_utils(apb_read_only_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT
    apb_master_read_seq master_seq;         // Read-only master sequence
    apb_slave_seq       slave_seq;         // Slave response sequence

    function new(string name = "apb_read_only_test", uvm_component parent = null);
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

        // Configure both agents as active for read testing
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
        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_read_only_test");

        // Phase 1: Basic read transactions with minimal delay
        $display("=== Read Only Test START ===");
        repeat(10) begin
            master_seq = apb_master_read_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive read transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide slave responses
            join
            #1ns;  // Minimal inter-transaction delay
        end

        // Phase 2: Read transactions with short delay
        $display("=== Read Only Test MIN DELAY ===");
        repeat(10) begin
            master_seq = apb_master_read_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #2ns;  // Short inter-transaction delay
        end

        // Phase 3: Read transactions with medium delay
        $display("=== Read Only Test MEDIUM DELAY ===");
        repeat(10) begin
            master_seq = apb_master_read_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #6ns;  // Medium inter-transaction delay
        end

        // Phase 4: Read transactions with maximum delay (back-to-back)
        $display("=== Read Only Test MAX DELAY ===");
        repeat(10) begin
            master_seq = apb_master_read_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            // No delay - back-to-back transactions
        end

        // Phase 5: Direct coverage sampling verification
        $display("=== Direct Coverage Sampling ===");
        begin
            apb_coverage cov = env.coverage;
            begin
                // Direct coverage sampling for various address/data patterns (READ transactions)
                cov.tr_type = 0; cov.addr = 32'h0000_1000; cov.data = 32'h0000_0000;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_2000; cov.data = 32'hFFFF_FFFF;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_3000; cov.data = 32'hAAAA_AAAA;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_4000; cov.data = 32'h1234_5678;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h4000_0000; cov.data = 32'h5A5A_5A5A;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h9000_0000; cov.data = 32'hCAFE_BABE;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_1004; cov.data = 32'h0000_0001;
                cov.apb_transaction_cg.sample();
                $display($sformatf("Transaction coverage after direct sampling: %0.2f%%",
                    cov.apb_transaction_cg.get_coverage()));
            end
        end

        #100ns;  // Allow time for final transactions to complete
        phase.drop_objection(this, "Finished apb_read_only_test");
    endtask

endclass

`endif
