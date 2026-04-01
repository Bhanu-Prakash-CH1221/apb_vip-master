//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_common_pkg.sv
// Description  : Common package with shared definitions and components
// Author       : CH Bhanu Prakash
// Notes        : Central package for all shared APB components
//-----------------------------------------------------------------------------

`ifndef _APB_COMMON_PKG_
`define _APB_COMMON_PKG_

package apb_common_pkg;
    
    // Import UVM framework and include macros
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Include APB protocol definitions and common components
    `include "apb_defines.svh"      // Protocol-wide constants
    `include "apb_base_seq_item.svh" // Base transaction item
    `include "apb_coverage.svh"      // Coverage collector
    
endpackage

`endif
