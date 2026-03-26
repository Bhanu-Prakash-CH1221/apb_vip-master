`ifndef _APB_TEST_PKG_
`define _APB_TEST_PKG_

package apb_test_pkg;

    import uvm_pkg::*;
    import apb_common_pkg::*;
    import apb_master_pkg::*;
    import apb_slave_pkg::*;
    `include "uvm_macros.svh"

    `include "apb_scoreboard.svh"
    `include "apb_env.svh"

    // Original 9 tests
    `include "tests/apb_basic_test.svh"
    `include "tests/apb_transaction_test.svh"
    `include "tests/apb_timing_test.svh"
    `include "tests/apb_read_only_test.svh"
    `include "tests/apb_write_only_test.svh"
    `include "tests/apb_passive_test.svh"
    `include "tests/apb_reset_test.svh"
    `include "tests/apb_protocol_test.svh"

    // New tests - order matters for factory test
    `include "tests/apb_nocfg_test.svh"
    `include "tests/apb_master_passive_test.svh"
    `include "tests/apb_uvm_macro_test.svh"
    `include "tests/apb_field_auto_test.svh"
    
    // Factory test last - after all other tests are defined
    `include "tests/apb_factory_test.svh"

endpackage

`endif