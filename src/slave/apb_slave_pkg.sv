//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_pkg.sv
// Description  : Slave agent package
// Author       : CH Bhanu Prakash
// Notes        : Package all slave agent components
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_PKG_
`define _APB_SLAVE_PKG_

package apb_slave_pkg;
    
    // Import required packages
    import uvm_pkg::*;
    import apb_common_pkg::*;
    
    // Include slave agent components in dependency order
    `include "apb_slave_config.svh"      // Configuration object
    `include "apb_slave_seq_item.svh"    // Slave-specific sequence item
    `include "apb_slave_seq.svh"          // Base slave sequence
    `include "apb_slave_sequencer.svh"    // Sequence executor
    `include "apb_slave_driver.svh"       // Bus driver
    `include "apb_slave_monitor.svh"      // Bus monitor
    `include "apb_slave_agent.svh"        // Top-level agent
endpackage

`endif