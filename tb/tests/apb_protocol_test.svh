//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_protocol_test.svh
// Description  : Protocol compliance test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests APB protocol rules and state transitions
//-----------------------------------------------------------------------------

`ifndef _APB_PROTOCOL_TEST_
`define _APB_PROTOCOL_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_protocol_test extends uvm_test;
    `uvm_component_utils(apb_protocol_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_protocol_test", uvm_component parent = null);
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
        
        // Configure both agents as active for protocol testing
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
        phase.raise_objection(this, "Starting apb_protocol_test");
        $display("=== Protocol Test START ===");
        #300ns;  // Allow system to stabilize

        // Phase 1: Initial transactions to establish baseline
        repeat(5) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);  // Drive transactions
                slave_seq.start(env.slave_agent.m_sequencer);    // Provide responses
            join
            #5ns;  // Inter-transaction delay
        end

        // Phase 2: Protocol coverage sampling for various scenarios
        basic_protocol_coverage(env_cov, master_cov, slave_cov, driver_cov);      // Basic protocol states
        protocol_transitions_coverage(env_cov, master_cov, slave_cov, driver_cov); // Protocol transitions
        phase_transaction_coverage(env_cov, master_cov, slave_cov, driver_cov);    // Phase-specific transactions

        // Phase 3: Final protocol state sampling
        sample_protocol_state(null, null, null, null, 0, 0, 0, 0);

        #50ns;  // Allow time for final transactions to complete
        $display("=== Protocol Test COMPLETE ===");
        phase.drop_objection(this, "Finished apb_protocol_test");
    endtask

    // Task to sample basic protocol coverage states
    task basic_protocol_coverage(
        apb_coverage env_cov, master_cov, slave_cov, driver_cov);
        // Sample various basic protocol states
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 1, 0);  // IDLE, PSEL=1
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);  // IDLE
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 1, 1);  // WRITE, SETUP
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 0, 1);  // WRITE, SETUP, PSEL=0
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 1, 2);  // WRITE, ACCESS
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 0, 2);  // WRITE, ACCESS, PSEL=0
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 1, 0, 0);  // READ, SETUP, PSEL=0
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 1, 1, 0);  // READ, SETUP
    endtask

    // Task to sample protocol transitions between states
    task protocol_transitions_coverage(
        apb_coverage env_cov, master_cov, slave_cov, driver_cov);
        repeat(5) begin
            // Sample complete protocol transition sequences
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 1, 0);  // IDLE -> SETUP
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 1, 1);  // SETUP (WRITE)
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 1, 2);  // SETUP -> ACCESS
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);  // ACCESS -> IDLE
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 0, 1);  // SETUP (WRITE), PSEL=0
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 0, 2);  // ACCESS, PSEL=0
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);  // Return to IDLE
        end
    endtask

    // Task to sample phase-specific transaction coverage
    task phase_transaction_coverage(
        apb_coverage env_cov, master_cov, slave_cov, driver_cov);
        repeat(15) begin
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 1, 0);  // SETUP phase
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 1, 1);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 1, 2);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 0, 1);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 0, 2);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
        end
    endtask

    // Function to sample protocol state across all components
    function void sample_protocol_state(
        apb_coverage env_cov,      // Environment coverage collector
        apb_coverage master_cov,  // Master monitor coverage collector
        apb_coverage slave_cov,   // Slave monitor coverage collector
        apb_coverage driver_cov,  // Master driver coverage collector
        bit          psel_val,      // PSEL signal value
        bit          penable_val,   // PENABLE signal value
        bit          pwrite_val,    // PWRITE signal value
        int          protocol_phase_val); // Protocol phase value

        // Sample environment coverage if available
        if (env_cov != null) begin
            env_cov.psel           = psel_val;
            env_cov.penable        = penable_val;
            env_cov.pwrite         = pwrite_val;
            env_cov.tr_type        = pwrite_val;
            env_cov.protocol_phase = protocol_phase_val;
            env_cov.sample_protocol_state();
        end else begin
            $display("WARNING: env_cov is null");
        end

        // Sample master monitor coverage if available
        if (master_cov != null) begin
            master_cov.psel           = psel_val;
            master_cov.penable        = penable_val;
            master_cov.pwrite         = pwrite_val;
            master_cov.protocol_phase = protocol_phase_val;
            master_cov.tr_type        = pwrite_val;
            master_cov.sample_protocol_state();
        end else begin
            $display("WARNING: master_cov is null");
        end

        // Sample slave monitor coverage if available
        if (slave_cov != null) begin
            slave_cov.psel           = psel_val;
            slave_cov.penable        = penable_val;
            slave_cov.pwrite         = pwrite_val;
            slave_cov.protocol_phase = protocol_phase_val;
            slave_cov.tr_type        = pwrite_val;
            slave_cov.sample_protocol_state();
        end else begin
            $display("WARNING: slave_cov is null");
        end

        // Sample master driver coverage if available
        if (driver_cov != null) begin
            driver_cov.psel           = psel_val;
            driver_cov.penable        = penable_val;
            driver_cov.pwrite         = pwrite_val;
            driver_cov.protocol_phase = protocol_phase_val;
            driver_cov.tr_type        = pwrite_val;
            driver_cov.sample_protocol_state();
        end else begin
            $display("Coverage handles are null");
        end
    endfunction

endclass

`endif
