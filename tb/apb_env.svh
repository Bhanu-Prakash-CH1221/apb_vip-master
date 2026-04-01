//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_env.svh
// Description  : Complete UVM testbench environment
// Author       : CH Bhanu Prakash
// Notes        : Top-level environment with master and slave agents
//-----------------------------------------------------------------------------

`ifndef _APB_ENV_
`define _APB_ENV_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)

    // Main APB verification environment components
    apb_master_agent  master_agent;  // Master agent for driving transactions
    apb_slave_agent   slave_agent;   // Slave agent for responding to transactions
    apb_scoreboard    scoreboard;    // Transaction checker for data integrity
    apb_coverage      coverage;      // Coverage collector for protocol verification
    virtual apb_if    vif;          // Virtual interface to DUT

    extern function new(string name = "apb_env", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function apb_env::new(string name = "apb_env", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Initialize factory methods for UVM component creation
    void'(get_object_type());
    void'(get_type_name());

    // Create all environment components using UVM factory
    master_agent = apb_master_agent::type_id::create("master_agent", this);
    slave_agent  = apb_slave_agent::type_id::create("slave_agent",   this);
    scoreboard   = apb_scoreboard::type_id::create("scoreboard",     this);
    coverage     = apb_coverage::type_id::create("coverage",         this);

    // Get virtual interface from testbench configuration
    void'(uvm_config_db#(virtual apb_if)::get(null, "", "apb_vif", vif));
    $display("ENV: Virtual interface obtained");

    // Connect virtual interface to all master agent components
    uvm_config_db#(virtual apb_if)::set(this, "master_agent.m_apb_master_driver",  "apb_vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "master_agent.m_apb_master_monitor", "apb_vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "slave_agent.m_apb_slave_driver",    "apb_vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "slave_agent.m_apb_slave_monitor",   "apb_vif", vif);

    // Share coverage object with all components and environment
    uvm_config_db#(apb_coverage)::set(this, "",    "coverage", coverage);
    uvm_config_db#(apb_coverage)::set(null, "env", "coverage", coverage);

    $display("ENV: build_phase complete");
endfunction

function void apb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect master monitor to scoreboard for transaction checking
    master_agent.m_apb_master_monitor.ap.connect(scoreboard.analysis_imp);
    master_agent.m_apb_master_monitor.ap.connect(coverage.analysis_imp);

    // Connect slave monitor to scoreboard and coverage
    slave_agent.m_apb_slave_monitor.ap.connect(scoreboard.analysis_imp);
    slave_agent.m_apb_slave_monitor.ap.connect(coverage.analysis_imp);

    $display("ENV: connect_phase complete");
endfunction

`endif
