//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_master_sequencer.svh
// Description  : Master sequencer component
// Author       : CH Bhanu Prakash
// Notes        : Sequence arbitration and execution for master agent
//-----------------------------------------------------------------------------

`ifndef _APB_MASTER_SEQUENCER_
`define _APB_MASTER_SEQUENCER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_master_sequencer extends uvm_sequencer#(apb_master_seq_item);
    `uvm_component_utils(apb_master_sequencer)

    function new(string name = "apb_master_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Initialize factory methods for UVM component creation
        void'(get_object_type());
        void'(get_type_name());
    endfunction
endclass

`endif