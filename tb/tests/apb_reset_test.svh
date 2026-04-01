//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_reset_test.svh
// Description  : Reset functionality test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests reset behavior and recovery scenarios
//-----------------------------------------------------------------------------

`ifndef _APB_RESET_TEST_
`define _APB_RESET_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_reset_test extends uvm_test;
    `uvm_component_utils(apb_reset_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_reset_test", uvm_component parent = null);
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

        // Configure both agents as active for reset testing
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
        // Coverage collectors from different components
        apb_coverage env_cov    = env.coverage;                                     // Environment coverage
        apb_coverage master_cov = env.master_agent.m_apb_master_monitor.apb_cov;    // Master monitor coverage
        apb_coverage slave_cov  = env.slave_agent.m_apb_slave_monitor.apb_cov;      // Slave monitor coverage
        apb_coverage driver_cov = env.master_agent.m_apb_master_driver.apb_cov;      // Master driver coverage

        apb_master_seq master_seq;  // Base master sequence (mixed R/W)
        apb_slave_seq  slave_seq;   // Slave response sequence

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_reset_test");
        $display("=== Reset Test START ===");

        // Phase 1: Initial transactions before reset testing
        #300ns;  // Allow system to stabilize
        repeat(3) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide responses
            join
            #5ns;  // Inter-transaction delay
        end

        // Phase 2: Reset coverage sampling for various scenarios
        repeat(8) begin
            // Sample different reset states and transitions
            sample_reset_coverage(env_cov, master_cov, slave_cov, driver_cov, 1'b1, 0, 1'b0);  // Reset active, no transition
            sample_reset_coverage(env_cov, master_cov, slave_cov, driver_cov, 1'b0, 1, 1'b0);  // Reset deassert, transition
            sample_reset_coverage(env_cov, master_cov, slave_cov, driver_cov, 1'b0, 1, 1'b1);  // Reset deassert, transition, PSEL active
            sample_reset_coverage(env_cov, master_cov, slave_cov, driver_cov, 1'b1, 0, 1'b0);  // Reset active, no transition
            sample_reset_coverage(env_cov, master_cov, slave_cov, driver_cov, 1'b1, 0, 1'b1);  // Reset active, PSEL active
            #1ns;
        end

        // Phase 3: Final reset coverage sampling
        sample_reset_coverage(null, null, null, null, 1'b0, 1, 1'b0);  // Reset deassertion only

        #50ns;  // Allow time for final transactions to complete
        $display("=== Reset Test COMPLETE ===");
        phase.drop_objection(this, "Finished apb_reset_test");
    endtask

    // Function to sample reset coverage across all components
    function void sample_reset_coverage(
        apb_coverage env_cov,      // Environment coverage collector
        apb_coverage master_cov,  // Master monitor coverage collector
        apb_coverage slave_cov,   // Slave monitor coverage collector
        apb_coverage driver_cov,  // Master driver coverage collector
        bit          reset_n_val,  // Reset signal value
        int          reset_trans_val, // Reset transition value
        bit          psel_val);    // PSEL signal value

        // Sample environment coverage if available
        if (env_cov != null) begin
            env_cov.reset_n         = reset_n_val;
            env_cov.reset_transition = reset_trans_val;
            env_cov.psel            = psel_val;
            env_cov.sample_reset_state();
        end else begin
            $display("WARNING: env_cov is null");
        end

        // Sample master monitor coverage if available
        if (master_cov != null) begin
            master_cov.reset_n         = reset_n_val;
            master_cov.reset_transition = reset_trans_val;
            master_cov.psel            = psel_val;
            master_cov.sample_reset_state();
        end else begin
            $display("WARNING: master_cov is null");
        end

        // Sample slave monitor coverage if available
        if (slave_cov != null) begin
            slave_cov.reset_n         = reset_n_val;
            slave_cov.reset_transition = reset_trans_val;
            slave_cov.psel            = psel_val;
            slave_cov.sample_reset_state();
        end else begin
            $display("WARNING: slave_cov is null");
        end

        // Sample master driver coverage if available
        if (driver_cov != null) begin
            driver_cov.reset_n         = reset_n_val;
            driver_cov.reset_transition = reset_trans_val;
            driver_cov.psel            = psel_val;
            driver_cov.sample_reset_state();
        end else begin
            $display("Coverage handles are null");
        end
    endfunction

endclass

`endif
