`ifndef _APB_ENV_
`define _APB_ENV_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)

    apb_master_agent  master_agent;
    apb_slave_agent   slave_agent;
    apb_scoreboard    scoreboard;
    apb_coverage      coverage;
    virtual apb_if    vif;

    extern function new(string name = "apb_env", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function apb_env::new(string name = "apb_env", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    master_agent = apb_master_agent::type_id::create("master_agent", this);
    slave_agent  = apb_slave_agent::type_id::create("slave_agent",   this);
    scoreboard   = apb_scoreboard::type_id::create("scoreboard",     this);
    coverage     = apb_coverage::type_id::create("coverage",         this);

    void'(uvm_config_db#(virtual apb_if)::get(null, "", "apb_vif", vif));
    $display("ENV: Virtual interface obtained");

    uvm_config_db#(virtual apb_if)::set(this, "master_agent.m_apb_master_driver",  "apb_vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "master_agent.m_apb_master_monitor", "apb_vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "slave_agent.m_apb_slave_driver",    "apb_vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "slave_agent.m_apb_slave_monitor",   "apb_vif", vif);

    uvm_config_db#(apb_coverage)::set(this, "",    "coverage", coverage);
    uvm_config_db#(apb_coverage)::set(null, "env", "coverage", coverage);

    $display("ENV: build_phase complete");
endfunction

function void apb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    master_agent.m_apb_master_monitor.ap.connect(scoreboard.analysis_imp);
    master_agent.m_apb_master_monitor.ap.connect(coverage.analysis_imp);

    slave_agent.m_apb_slave_monitor.ap.connect(scoreboard.analysis_imp);
    slave_agent.m_apb_slave_monitor.ap.connect(coverage.analysis_imp);

    $display("ENV: connect_phase complete");
endfunction

`endif
