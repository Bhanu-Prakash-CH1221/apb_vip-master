//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_test_pkg.sv
// Description  : Test package with all test classes and components
// Author       : CH Bhanu Prakash
// Notes        : Central package for all testbench components
//-----------------------------------------------------------------------------

`ifndef _APB_TEST_PKG_
`define _APB_TEST_PKG_

package apb_test_pkg;

    // Import required UVM and APB packages
    import uvm_pkg::*;
    import apb_common_pkg::*;
    import apb_master_pkg::*;
    import apb_slave_pkg::*;
    `include "uvm_macros.svh"

    // Include core testbench components
    `include "apb_scoreboard.svh"
    `include "apb_env.svh"

    // Include all test classes in order of execution
    `include "tests/apb_basic_test.svh"         // Basic functionality test
    `include "tests/apb_transaction_test.svh"     // Transaction integrity test
    `include "tests/apb_timing_test.svh"          // Timing scenarios test
    `include "tests/apb_read_only_test.svh"         // Read operations test
    `include "tests/apb_write_only_test.svh"        // Write operations test
    `include "tests/apb_passive_test.svh"           // Passive mode test
    `include "tests/apb_reset_test.svh"             // Reset behavior test
    `include "tests/apb_protocol_test.svh"           // Protocol compliance test

    // Configuration and utility tests
    `include "tests/apb_nocfg_test.svh"             // No configuration test
    `include "tests/apb_master_passive_test.svh"     // Master passive mode test
    `include "tests/apb_uvm_macro_test.svh"          // UVM macro test
    `include "tests/apb_field_auto_test.svh"           // Field automation test
    
    // Comprehensive factory coverage test
    `include "tests/apb_factory_test.svh"

endpackage

`endif