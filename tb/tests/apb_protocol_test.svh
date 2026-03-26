`ifndef _APB_PROTOCOL_TEST_
`define _APB_PROTOCOL_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_protocol_test extends uvm_test;
    `uvm_component_utils(apb_protocol_test)

    apb_env           env;
    apb_master_config m_apb_master_config;
    apb_slave_config  m_apb_slave_config;
    virtual apb_if    vif;

    function new(string name = "apb_protocol_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env                 = apb_env::type_id::create("env", this);
        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");
        m_apb_master_config.is_active = apb_master_config::UVM_ACTIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;
        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("Virtual interface obtained");
    endfunction

    task run_phase(uvm_phase phase);
        apb_coverage env_cov    = env.coverage;
        apb_coverage master_cov = env.master_agent.m_apb_master_monitor.apb_cov;
        apb_coverage slave_cov  = env.slave_agent.m_apb_slave_monitor.apb_cov;
        apb_coverage driver_cov = env.master_agent.m_apb_master_driver.apb_cov;
        apb_master_seq master_seq;
        apb_slave_seq  slave_seq;

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_protocol_test");
        $display("=== Protocol Test START ===");
        #300ns;

        repeat(5) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #5ns;
        end

        basic_protocol_coverage(env_cov, master_cov, slave_cov, driver_cov);
        protocol_transitions_coverage(env_cov, master_cov, slave_cov, driver_cov);
        phase_transaction_coverage(env_cov, master_cov, slave_cov, driver_cov);

        // null-arm FEC
        sample_protocol_state(null, null, null, null, 0, 0, 0, 0);

        #50ns;
        $display("=== Protocol Test COMPLETE ===");
        phase.drop_objection(this, "Finished apb_protocol_test");
    endtask

    task basic_protocol_coverage(
        apb_coverage env_cov, master_cov, slave_cov, driver_cov);
        // IDLE (protocol_phase=0) x WRITE and READ — hits IDLE_WRITE / IDLE_READ bins
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 1, 0);
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
        // SETUP phase
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 1, 1);
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 0, 1);
        // ACCESS phase
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 1, 2);
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 0, 2);
        // PSEL=0,PENABLE=1 state (PSEL_LOW + PENABLE_HIGH bins)
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 1, 0, 0);
        sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 1, 1, 0);
    endtask

    task protocol_transitions_coverage(
        apb_coverage env_cov, master_cov, slave_cov, driver_cov);
        repeat(5) begin
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 1, 0);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 1, 1);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 1, 2);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 0, 1);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 0, 2);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
        end
    endtask

    task phase_transaction_coverage(
        apb_coverage env_cov, master_cov, slave_cov, driver_cov);
        repeat(15) begin
            // IDLE x WRITE
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 1, 0);
            // SETUP_WRITE
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 1, 1);
            // ACCESS_WRITE
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 1, 2);
            // IDLE x READ
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
            // SETUP_READ
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 0, 0, 1);
            // ACCESS_READ
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 1, 1, 0, 2);
            sample_protocol_state(env_cov, master_cov, slave_cov, driver_cov, 0, 0, 0, 0);
        end
    endtask

    function void sample_protocol_state(
        apb_coverage env_cov,
        apb_coverage master_cov,
        apb_coverage slave_cov,
        apb_coverage driver_cov,
        bit          psel_val,
        bit          penable_val,
        bit          pwrite_val,
        int          protocol_phase_val);

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
