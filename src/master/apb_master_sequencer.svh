`ifndef _APB_MASTER_SEQUENCER_
`define _APB_MASTER_SEQUENCER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_master_sequencer extends uvm_sequencer#(apb_master_seq_item);
    `uvm_component_utils(apb_master_sequencer)

    function new(string name = "apb_master_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    // Removed duplicate get_type_name - inherited from uvm_component
endclass

`endif