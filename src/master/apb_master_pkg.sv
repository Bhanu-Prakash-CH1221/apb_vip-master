`ifndef _APB_MASTER_PKG_
`define _APB_MASTER_PKG_

package apb_master_pkg;
    import uvm_pkg::*;
    import apb_common_pkg::*;
    
    `include "apb_master_config.svh"
    `include "apb_master_seq_item.svh"
    `include "apb_master_seq.svh"
    `include "apb_master_read_seq.svh"
    `include "apb_master_write_seq.svh"
    `include "apb_master_sequencer.svh"
    `include "apb_master_driver.svh"
    `include "apb_master_monitor.svh"
    `include "apb_master_agent.svh"
endpackage

`endif