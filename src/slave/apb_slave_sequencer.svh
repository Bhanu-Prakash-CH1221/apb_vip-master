//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_sequencer.svh
// Description  : Slave sequencer component
// Author       : CH Bhanu Prakash
// Notes        : Sequence arbitration and execution for slave agent
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_SEQUENCER_
`define _APB_SLAVE_SEQUENCER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_sequencer extends uvm_sequencer#(apb_slave_seq_item);
    `uvm_component_utils(apb_slave_sequencer)

    function new(string name = "apb_slave_sequencer", uvm_component parent = null);
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