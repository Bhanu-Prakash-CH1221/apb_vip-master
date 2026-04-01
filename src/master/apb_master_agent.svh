//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_master_agent.svh
// Description  : Master agent component
// Author       : CH Bhanu Prakash
// Notes        : Top-level master agent container with driver, monitor, sequencer
//-----------------------------------------------------------------------------

`ifndef _APB_MASTER_AGENT_
`define _APB_MASTER_AGENT_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;

class apb_master_agent extends uvm_agent;
    `uvm_component_utils(apb_master_agent)

    // Master agent components
    apb_master_config     m_cfg;              // Configuration object
    apb_master_seq_item   m_apb_master_seq_item; // Sequence item template
    apb_master_driver     m_apb_master_driver;   // Driver for active mode
    apb_master_seq        m_apb_master_seq;      // Base sequence
    apb_master_sequencer  m_sequencer;           // Sequencer for active mode
    apb_master_monitor    m_apb_master_monitor;  // Monitor 

    extern function new(string name = "apb_master_agent", uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function apb_master_agent::new(string name = "apb_master_agent", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Initialize factory methods for UVM component creation
    void'(get_object_type());
    void'(get_type_name());

    // Get configuration from config database or create default
    if (!uvm_config_db#(apb_master_config)::get(this, "", "apb_master_config", m_cfg)) begin
        $display("MASTER_AGENT: no config found - using default ACTIVE");
        m_cfg = apb_master_config::type_id::create("m_cfg");
    end

    // Create common components (always created)
    m_apb_master_seq_item = apb_master_seq_item::type_id::create("m_apb_master_seq_item");
    m_apb_master_seq      = apb_master_seq::type_id::create("m_apb_master_seq");
    m_apb_master_monitor  = apb_master_monitor::type_id::create("m_apb_master_monitor", this);

    // Create active mode components only if configured as active
    if (m_cfg.is_active == apb_master_config::UVM_ACTIVE) begin
        m_apb_master_driver = apb_master_driver::type_id::create("m_apb_master_driver", this);
        m_sequencer         = apb_master_sequencer::type_id::create("m_sequencer", this);
        $display("MASTER_AGENT: ACTIVE - driver + sequencer created");
    end else begin
        // Passive mode: no driver or sequencer needed
        m_apb_master_driver = null;
        m_sequencer         = null;
        $display("MASTER_AGENT: PASSIVE - no driver / sequencer");
    end
endfunction

function void apb_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (m_cfg.is_active == apb_master_config::UVM_ACTIVE) begin
        // Connect driver to sequencer for active mode
        m_apb_master_driver.seq_item_port.connect(m_sequencer.seq_item_export);
        $display("MASTER_AGENT: driver connected to sequencer");
    end else begin
        // Passive mode: no connections needed
        $display("MASTER_AGENT: PASSIVE - no connect needed");
    end
endfunction

`endif