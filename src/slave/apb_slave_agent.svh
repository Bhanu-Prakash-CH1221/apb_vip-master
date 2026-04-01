//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_agent.svh
// Description  : Slave agent component
// Author       : CH Bhanu Prakash
// Notes        : Top-level slave agent container with driver, monitor, sequencer
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_AGENT_
`define _APB_SLAVE_AGENT_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;

class apb_slave_agent extends uvm_agent;
    `uvm_component_utils(apb_slave_agent)

    // Slave agent components
    apb_slave_config     m_cfg;              // Configuration object
    apb_slave_seq_item   m_apb_slave_seq_item; // Sequence item template
    apb_slave_driver     m_apb_slave_driver;   // Driver for active mode
    apb_slave_seq        m_apb_slave_seq;      // Base sequence
    apb_slave_sequencer  m_sequencer;           // Sequencer for active mode
    apb_slave_monitor    m_apb_slave_monitor;  // Monitor (always created)

    extern function new(string name = "apb_slave_agent", uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
endclass

function apb_slave_agent::new(string name = "apb_slave_agent", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_slave_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Initialize factory methods for UVM component creation
    void'(get_object_type());
    void'(get_type_name());

    // Get configuration from config database or create default
    if (!uvm_config_db#(apb_slave_config)::get(this, "", "apb_slave_config", m_cfg)) begin
        $display("SLAVE_AGENT: no config found - using default ACTIVE");
        m_cfg = apb_slave_config::type_id::create("m_cfg");
    end

    // Create common components (always created)
    m_apb_slave_seq_item = apb_slave_seq_item::type_id::create("m_apb_slave_seq_item");
    m_apb_slave_seq      = apb_slave_seq::type_id::create("m_apb_slave_seq");
    m_apb_slave_monitor  = apb_slave_monitor::type_id::create("m_apb_slave_monitor", this);

    // Create active mode components only if configured as active
    if (m_cfg.is_active == apb_slave_config::UVM_ACTIVE) begin
        m_apb_slave_driver = apb_slave_driver::type_id::create("m_apb_slave_driver", this);
        m_sequencer        = apb_slave_sequencer::type_id::create("m_sequencer", this);
        $display("SLAVE_AGENT: ACTIVE - driver + sequencer created");
    end else begin
        m_apb_slave_driver = null;
        m_sequencer        = null;
        $display("SLAVE_AGENT: PASSIVE - no driver / sequencer");
    end
endfunction

function void apb_slave_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (m_cfg.is_active == apb_slave_config::UVM_ACTIVE) begin
        // Connect driver to sequencer for active mode
        m_apb_slave_driver.seq_item_port.connect(m_sequencer.seq_item_export);
        $display("SLAVE_AGENT: driver connected to sequencer");
    end else begin
        // Passive mode: no connections needed
        $display("SLAVE_AGENT: PASSIVE - no connect needed");
    end
endfunction

`endif