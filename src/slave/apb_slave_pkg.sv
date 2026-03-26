`ifndef _APB_SLAVE_PKG_
`define _APB_SLAVE_PKG_

package apb_slave_pkg;
    import uvm_pkg::*;
    import apb_common_pkg::*;
    
    `include "apb_slave_config.svh"
    `include "apb_slave_seq_item.svh"
    `include "apb_slave_seq.svh"
    `include "apb_slave_sequencer.svh"
    `include "apb_slave_driver.svh"
    `include "apb_slave_monitor.svh"
    `include "apb_slave_agent.svh"
endpackage

`endif