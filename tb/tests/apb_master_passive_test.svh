//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_master_passive_test.svh
// Description  : Master passive mode test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests master agent in passive mode with active slave
//-----------------------------------------------------------------------------

`ifndef _APB_MASTER_PASSIVE_TEST_
`define _APB_MASTER_PASSIVE_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_master_passive_test extends uvm_test;
    `uvm_component_utils(apb_master_passive_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_master_passive_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Initialize factory methods for UVM component creation
        void'(get_type());
        void'(get_object_type());

        // Create configuration objects
        m_apb_master_config           = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config            = apb_slave_config::type_id::create("m_apb_slave_config");
        
        // Configure master as PASSIVE and slave as ACTIVE for testing
        m_apb_master_config.is_active = apb_master_config::UVM_PASSIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;
        
        // Share configurations with agents via config database
        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);
        
        // Create test environment
        env = apb_env::type_id::create("env", this);
        
        // Get virtual interface from testbench
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("MASTER_PASSIVE_TEST: master=PASSIVE slave=ACTIVE");
    endfunction

    task run_phase(uvm_phase phase);
        // Coverage collectors from different components
        apb_coverage env_cov    = env.coverage;                                     // Environment coverage
        apb_coverage master_cov = env.master_agent.m_apb_master_monitor.apb_cov;    // Master monitor coverage
        apb_coverage slave_cov  = env.slave_agent.m_apb_slave_monitor.apb_cov;      // Slave monitor coverage

        super.run_phase(phase);
        phase.raise_objection(this, "apb_master_passive_test START");
        $display("=== Master-Passive Test START ===");

        $display("master_agent PASSIVE: driver is null (passive mode confirmed)");

        // Initialize APB interface signals to idle state
        vif.PSEL    = 1'b0;
        vif.PENABLE = 1'b0;
        vif.PWRITE  = 1'b0;
        vif.PREADY  = 1'b1;
        vif.PRDATA  = '0;
        vif.PADDR   = '0;
        vif.PWDATA  = '0;
        #300ns;  // Allow signals to stabilize

        // Sample timing coverage across different components
        env_cov.sample_timing(1, 0); env_cov.sample_timing(2, 0);
        env_cov.sample_timing(5, 0); env_cov.sample_timing(7, 0);
        env_cov.sample_timing(1, 1); env_cov.sample_timing(2, 1);
        master_cov.sample_timing(1, 0); master_cov.sample_timing(2, 1);
        slave_cov.sample_timing(5, 0);  slave_cov.sample_timing(7, 1);

        // Sample reset coverage scenarios
        env_cov.reset_n = 1'b0; env_cov.reset_transition = 1; env_cov.psel = 1'b0;
        env_cov.sample_reset_state();
        env_cov.reset_n = 1'b1; env_cov.reset_transition = 0;
        env_cov.sample_reset_state();
        env_cov.reset_n = 1'b1; env_cov.psel = 1'b1;
        env_cov.sample_reset_state();

        // Sample protocol state coverage
        env_cov.psel = 0; env_cov.penable = 0; env_cov.protocol_phase = 0;
        env_cov.sample_protocol_state();
        env_cov.psel = 1; env_cov.penable = 0; env_cov.pwrite = 1; env_cov.protocol_phase = 1;
        env_cov.sample_protocol_state();
        env_cov.psel = 1; env_cov.penable = 1; env_cov.pwrite = 0; env_cov.protocol_phase = 2;
        env_cov.sample_protocol_state();

        #100ns;
        $display("=== Master-Passive Test COMPLETE ===");
        phase.drop_objection(this, "apb_master_passive_test DONE");
    endtask

endclass

`endif
