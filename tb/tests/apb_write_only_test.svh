//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_write_only_test.svh
// Description  : Write-only operations test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests write transactions with various timing scenarios
//-----------------------------------------------------------------------------

`ifndef _APB_WRITE_ONLY_TEST_
`define _APB_WRITE_ONLY_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_write_only_test extends uvm_test;
    `uvm_component_utils(apb_write_only_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_write_only_test", uvm_component parent = null);
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

        // Configure both agents as active for write testing
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
        apb_master_write_seq master_seq;  // Write-only master sequence
        apb_slave_seq       slave_seq;   // Slave response sequence

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_write_only_test");

        // Phase 1: Basic write transactions with minimal delay
        $display("=== Write Only Test START ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive write transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide slave responses
            join
            #1ns;  // Minimal inter-transaction delay
        end

        // Phase 2: Write transactions with short delay
        $display("=== Write Only Test MIN DELAY ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #2ns;  // Short inter-transaction delay
        end;

        // Phase 3: Write transactions with medium delay
        $display("=== Write Only Test MEDIUM DELAY ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #8ns;  // Medium inter-transaction delay
        end

        // Phase 4: Write transactions with maximum delay (back-to-back)
        $display("=== Write Only Test MAX DELAY ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
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
                // Direct coverage sampling for various address/data patterns
                cov.tr_type = 1; cov.addr = 32'h0000_1000; cov.data = 32'h0000_0000;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_2000; cov.data = 32'hFFFF_FFFF;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_3000; cov.data = 32'hAAAA_AAAA;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_4000; cov.data = 32'h1234_5678;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h4000_0000; cov.data = 32'hDEAD_BEEF;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h9000_0000; cov.data = 32'hCAFE_BABE;
                cov.apb_transaction_cg.sample();
                cov.addr = 32'h0000_1000; cov.data = 32'h0000_00AB;
                cov.apb_transaction_cg.sample();
                $display($sformatf("Transaction coverage after direct sampling: %0.2f%%",
                    cov.apb_transaction_cg.get_coverage()));
            end
        end

        // Scoreboard write testing for write transactions
        begin
            apb_base_seq_item tw1, tw2;
            // Test 1: Initial write to scoreboard
            tw1 = apb_base_seq_item::type_id::create("tw1");
            tw1.apb_tr = apb_base_seq_item::WRITE;
            tw1.addr   = 32'h0000_CAFE;
            tw1.data   = 32'hAAAA_AAAA;
            env.scoreboard.write(tw1);

            // Test 2: Write to same address with different data (OVERWRITE case)
            tw2 = apb_base_seq_item::type_id::create("tw2");
            tw2.apb_tr = apb_base_seq_item::WRITE;
            tw2.addr   = 32'h0000_CAFE;   // same address
            tw2.data   = 32'hBBBB_BBBB;   // different data -> OVERWRITE branch
            env.scoreboard.write(tw2);

            // Test 3: Write to same address with same data (SAME VALUE case)
            tw2.data   = 32'hAAAA_AAAA;   // same data -> SAME VALUE branch
            env.scoreboard.write(tw2);
        end

        #100ns;  // Allow time for final transactions to complete
        phase.drop_objection(this, "Finished apb_write_only_test");
    endtask

endclass

`endif
