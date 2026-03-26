`ifndef _APB_MASTER_AGENT_
`define _APB_MASTER_AGENT_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;

class apb_master_agent extends uvm_agent;
    `uvm_component_utils(apb_master_agent)

    apb_master_config     m_cfg;
    apb_master_seq_item   m_apb_master_seq_item;
    apb_master_driver     m_apb_master_driver;
    apb_master_seq        m_apb_master_seq;
    apb_master_sequencer  m_sequencer;
    apb_master_monitor    m_apb_master_monitor;

    extern function new(string name = "apb_master_agent", uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function apb_master_agent::new(string name = "apb_master_agent", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // BRANCH FIX: Single uvm_config_db::get with $display (NOT uvm_info/uvm_warning).
    // uvm_info/uvm_warning macros each expand to an internal verbosity-check IF
    // branch that is unreachable when verbosity = UVM_NONE (quiet run) for info
    // and always-enabled for warning → impossible ALL_FALSE arm.
    // Using $display has no hidden branches.
    //
    // Branch TRUE  (FALSE path of get): apb_nocfg_test (no config set)
    // Branch FALSE (TRUE path of get) : all other tests (config IS set)
    if (!uvm_config_db#(apb_master_config)::get(this, "", "apb_master_config", m_cfg)) begin
        $display("MASTER_AGENT: no config found - using default ACTIVE");
        m_cfg = apb_master_config::type_id::create("m_cfg");
    end

    m_apb_master_seq_item = apb_master_seq_item::type_id::create("m_apb_master_seq_item");
    m_apb_master_seq      = apb_master_seq::type_id::create("m_apb_master_seq");
    m_apb_master_monitor  = apb_master_monitor::type_id::create("m_apb_master_monitor", this);

    // Branch TRUE  (UVM_ACTIVE):  all active tests
    // Branch FALSE (UVM_PASSIVE): apb_master_passive_test
    if (m_cfg.is_active == apb_master_config::UVM_ACTIVE) begin
        m_apb_master_driver = apb_master_driver::type_id::create("m_apb_master_driver", this);
        m_sequencer         = apb_master_sequencer::type_id::create("m_sequencer", this);
        $display("MASTER_AGENT: ACTIVE - driver + sequencer created");
    end else begin
        m_apb_master_driver = null;
        m_sequencer         = null;
        $display("MASTER_AGENT: PASSIVE - no driver / sequencer");
    end
endfunction

function void apb_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Branch TRUE  (ACTIVE):  connect driver → sequencer
    // Branch FALSE (PASSIVE): skip
    if (m_cfg.is_active == apb_master_config::UVM_ACTIVE) begin
        m_apb_master_driver.seq_item_port.connect(m_sequencer.seq_item_export);
        $display("MASTER_AGENT: driver connected to sequencer");
    end else begin
        $display("MASTER_AGENT: PASSIVE - no connect needed");
    end
endfunction

`endif