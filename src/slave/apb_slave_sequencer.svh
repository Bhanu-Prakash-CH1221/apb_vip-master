`ifndef _APB_SLAVE_SEQUENCER_
`define _APB_SLAVE_SEQUENCER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_sequencer extends uvm_sequencer#(apb_slave_seq_item);
    `uvm_component_utils(apb_slave_sequencer)

    function new(string name = "apb_slave_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    // Removed duplicate get_type_name - inherited from uvm_component
endclass

`endif