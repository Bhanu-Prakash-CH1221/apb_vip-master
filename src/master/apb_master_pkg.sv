//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_master_pkg.sv
// Description  : Master agent package
// Author       : CH Bhanu Prakash
// Notes        : Package all master agent components
//-----------------------------------------------------------------------------

`ifndef _APB_MASTER_PKG_
`define _APB_MASTER_PKG_

package apb_master_pkg;
    
    // Import required packages
    import uvm_pkg::*;
    import apb_common_pkg::*;
    
    // Include master agent components in dependency order
    `include "apb_master_config.svh"      // Configuration object
    `include "apb_master_seq_item.svh"    // Master-specific sequence item
    `include "apb_master_seq.svh"          // Base master sequence
    `include "apb_master_read_seq.svh"     // Read-specific sequence
    `include "apb_master_write_seq.svh"    // Write-specific sequence
    `include "apb_master_sequencer.svh"    // Sequence executor
    `include "apb_master_driver.svh"       // Bus driver
    `include "apb_master_monitor.svh"      // Bus monitor
    `include "apb_master_agent.svh"        // Top-level agent
endpackage

`endif