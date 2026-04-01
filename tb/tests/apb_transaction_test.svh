//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_transaction_test.svh
// Description  : Transaction integrity test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests transaction data integrity and protocol compliance
//-----------------------------------------------------------------------------

`ifndef _APB_TRANSACTION_TEST_
`define _APB_TRANSACTION_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_transaction_test extends uvm_test;
    `uvm_component_utils(apb_transaction_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT
    
    // Saved component references for testing
    apb_master_driver saved_driver;         // Master driver reference
    apb_master_monitor saved_monitor;       // Master monitor reference
    apb_slave_monitor saved_slave_monitor;  // Slave monitor reference

    function new(string name = "apb_transaction_test", uvm_component parent = null);
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
        
        // Configure both agents as active for transaction testing
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
        phase.raise_objection(this, "Starting apb_transaction_test");

        $display("=== Transaction Test START ===");
        run_basic_sequences();                     // Run basic verification sequences

        $display("=== Missing Transaction Bins ===");
        sample_missing_transaction_bins();         // Sample missing coverage bins

        $display("=== Transaction Coverage All ===");
        sample_transaction_coverage_all();          // Sample comprehensive coverage

        force_prdata_toggle();                     // Force PRDATA signal toggling
        force_paddr_toggle();                      // Force PADDR signal toggling
        
        // Save component references for null testing
        saved_driver = env.master_agent.m_apb_master_driver;
        saved_monitor = env.master_agent.m_apb_master_monitor;
        saved_slave_monitor = env.slave_agent.m_apb_slave_monitor;
        
        // Test with null components (error handling)
        env.master_agent.m_apb_master_driver = null;
        env.master_agent.m_apb_master_monitor = null;
        env.slave_agent.m_apb_slave_monitor = null;
        
        sample_transaction_coverage(32'h0000_5000, 32'h5555_5555, apb_base_seq_item::WRITE);
        
        // Restore component references
        env.master_agent.m_apb_master_driver = saved_driver;
        env.master_agent.m_apb_master_monitor = saved_monitor;
        env.slave_agent.m_apb_slave_monitor = saved_slave_monitor;

        $display("=== Transaction Test COMPLETE ===");
        phase.drop_objection(this, "Finished apb_transaction_test");
    endtask

    // Task to run basic verification sequences
    task run_basic_sequences();
        apb_master_seq master_seq;  // Base master sequence (mixed R/W)
        apb_slave_seq  slave_seq;   // Slave response sequence
        repeat(5) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide responses
            join
            #10ns;  // Inter-transaction delay
        end
    endtask;

    // Task to sample missing transaction coverage bins
    task sample_missing_transaction_bins();
        // Sample various address/data patterns for missing coverage
        sample_transaction_coverage(32'h0000_1000, 32'h0000_0000, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_2000, 32'hFFFF_FFFF, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_3000, 32'hAAAA_AAAA, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_4000, 32'h1234_5678, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h4000_0000, 32'hDEAD_BEEF, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h9000_0000, 32'hCAFE_BABE, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_1004, 32'h0000_00AB, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_1000, 32'h0000_0000, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_2000, 32'hFFFF_FFFF, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_3000, 32'hAAAA_AAAA, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_4000, 32'h5A5A_5A5A, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h4000_0000, 32'h0000_0000, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h9000_0000, 32'hFFFF_FFFF, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0002, 32'h5555_5555, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0006, 32'hAAAAAAAA, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_000A, 32'hCCCC_CCCC, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0010, 32'hF0F0_F0F0, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0020, 32'h0F0F_0F0F, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0040, 32'hFF00_FF00, apb_base_seq_item::READ);
    endtask;

    function void sample_transaction_coverage(
        bit [31:0]                                   addr_val,
        bit [31:0]                                   data_val,
        apb_base_seq_item::apb_transfer_direction_t  tr_type_val);

        bit tr = (tr_type_val == apb_base_seq_item::WRITE) ? 1 : 0;

        env.coverage.addr    = addr_val;
        env.coverage.data    = data_val;
        env.coverage.tr_type = tr;
        env.coverage.apb_transaction_cg.sample();

        if (env.master_agent.m_apb_master_driver != null) begin
            env.master_agent.m_apb_master_driver.apb_cov.addr    = addr_val;
            env.master_agent.m_apb_master_driver.apb_cov.data    = data_val;
            env.master_agent.m_apb_master_driver.apb_cov.tr_type = tr;
            env.master_agent.m_apb_master_driver.apb_cov.apb_transaction_cg.sample();
        end

        if (env.master_agent.m_apb_master_monitor != null) begin
            env.master_agent.m_apb_master_monitor.apb_cov.addr    = addr_val;
            env.master_agent.m_apb_master_monitor.apb_cov.data    = data_val;
            env.master_agent.m_apb_master_monitor.apb_cov.tr_type = tr;
            env.master_agent.m_apb_master_monitor.apb_cov.apb_transaction_cg.sample();
        end

        if (env.slave_agent.m_apb_slave_monitor != null) begin
            env.slave_agent.m_apb_slave_monitor.apb_cov.addr    = addr_val;
            env.slave_agent.m_apb_slave_monitor.apb_cov.data    = data_val;
            env.slave_agent.m_apb_slave_monitor.apb_cov.tr_type = tr;
            env.slave_agent.m_apb_slave_monitor.apb_cov.apb_transaction_cg.sample();
        end
    endfunction

    task sample_transaction_coverage_all();
        sample_transaction_coverage(32'h0000_0000, 32'h0000_0000, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0000, 32'hFFFF_FFFF, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0000, 32'hAAAA_AAAA, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0000, 32'h1234_5678, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h4000_0000, 32'h0000_0000, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h4000_0000, 32'hFFFF_FFFF, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h4000_0000, 32'hAAAA_AAAA, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h8000_0000, 32'h0000_0000, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h8000_0000, 32'hFFFF_FFFF, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h8000_0000, 32'hAAAA_AAAA, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h8000_0000, 32'h5A5A_5A5A, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0000, 32'h0000_0000, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0000, 32'hFFFF_FFFF, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0000, 32'hAAAA_AAAA, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0000, 32'h1234_5678, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h4000_0000, 32'h0000_0000, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h4000_0000, 32'hFFFF_FFFF, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h4000_0000, 32'hAAAA_AAAA, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h8000_0000, 32'h0000_0000, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h8000_0000, 32'hFFFF_FFFF, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h8000_0000, 32'hAAAA_AAAA, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h8000_0000, 32'h5A5A_5A5A, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0004, 32'hDEAD_BEEF, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_0008, 32'hCAFE_BABE, apb_base_seq_item::WRITE);
        sample_transaction_coverage(32'h0000_000C, 32'h1234_5678, apb_base_seq_item::READ);
        sample_transaction_coverage(32'h0000_0010, 32'h9ABC_DEF0, apb_base_seq_item::READ);
    endtask

    task force_prdata_toggle();
        $display("=== Forcing PRDATA_out toggle for RTL toggle coverage ===");
        #20ns;
        wait(vif.PSEL == 1'b0 && vif.PENABLE == 1'b0);

        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b1;
        vif.PADDR   <= 32'h0000_0004;
        vif.PWRITE  <= 1'b1;
        vif.PWDATA  <= 32'hFFFF_FFFF;
        vif.PENABLE <= 1'b0;
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b1;
        vif.PREADY  <= 1'b1;
        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PREADY  <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PWDATA  <= 32'h0;
        @(posedge vif.PCLK);

        vif.PSEL    <= 1'b1;
        vif.PADDR   <= 32'h0000_0004;
        vif.PWRITE  <= 1'b0;
        vif.PENABLE <= 1'b0;
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b1;
        vif.PREADY  <= 1'b1;
        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PREADY  <= 1'b0;
        @(posedge vif.PCLK);

        $display("PRDATA_out should now be 0xFFFF_FFFF (all bits 0->1 toggled)");

        vif.PSEL    <= 1'b1;
        vif.PADDR   <= 32'h0000_0004;
        vif.PWRITE  <= 1'b1;
        vif.PWDATA  <= 32'h0000_0000;
        vif.PENABLE <= 1'b0;
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b1;
        vif.PREADY  <= 1'b1;
        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PREADY  <= 1'b0;
        vif.PWRITE  <= 1'b0;
        vif.PWDATA  <= 32'h0;
        @(posedge vif.PCLK);

        vif.PSEL    <= 1'b1;
        vif.PADDR   <= 32'h0000_0004;
        vif.PWRITE  <= 1'b0;
        vif.PENABLE <= 1'b0;
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b1;
        vif.PREADY  <= 1'b1;
        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;
        vif.PREADY  <= 1'b0;
        @(posedge vif.PCLK);

        $display("=== PRDATA_out all-bits toggle complete ===");
    endtask
    
    task force_paddr_toggle();
        $display("=== Forcing PADDR toggle for RTL toggle coverage ===");
        #20ns;
        wait(vif.PSEL == 1'b0 && vif.PENABLE == 1'b0);
        
        for (int i = 0; i < 32; i++) begin
            bit [31:0] test_addr = (1 << i) & 32'h0000_FFFF;
            if (test_addr != 0) begin
                @(posedge vif.PCLK);
                vif.PSEL    <= 1'b1;
                vif.PADDR   <= test_addr;
                vif.PWRITE  <= 1'b1;
                vif.PWDATA  <= 32'hDEAD_BEEF;
                vif.PENABLE <= 1'b0;
                @(posedge vif.PCLK);
                vif.PENABLE <= 1'b1;
                vif.PREADY  <= 1'b1;
                @(posedge vif.PCLK);
                vif.PSEL    <= 1'b0;
                vif.PENABLE <= 1'b0;
                vif.PREADY  <= 1'b0;
                vif.PWRITE  <= 1'b0;
                vif.PWDATA  <= 32'h0;
                @(posedge vif.PCLK);
            end
        end
        
        $display("=== PADDR all-bits toggle complete ===");
    endtask

endclass

`endif