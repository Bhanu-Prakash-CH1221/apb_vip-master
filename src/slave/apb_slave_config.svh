//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_config.svh
// Description  : Slave agent configuration object
// Author       : CH Bhanu Prakash
// Notes        : Configuration parameters for APB slave agent
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_CONFIG_
`define _APB_SLAVE_CONFIG_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_config extends uvm_object;
    
    // Agent mode enumeration
    typedef enum {UVM_ACTIVE, UVM_PASSIVE} uvm_active_passive_enum;
    
    // Configuration parameters
    uvm_active_passive_enum is_active      = UVM_ACTIVE;  // Agent mode (active/passive)
    bit                     has_coverage   = 0;          // Enable coverage collection
    bit                     has_scoreboard = 0;          // Enable scoreboard checking
    
    // UVM factory registration for object creation
    typedef uvm_object_registry#(apb_slave_config, "apb_slave_config") type_id;
    static function type_id get_type(); return type_id::get(); endfunction
    virtual function uvm_object_wrapper get_object_type(); return type_id::get(); endfunction
    virtual function string get_type_name(); return "apb_slave_config"; endfunction
    virtual function uvm_object create(string name="");
        apb_slave_config tmp = new(name); return tmp;
    endfunction

    function new(string name = "apb_slave_config");
        super.new(name);
    endfunction

    // Deep copy implementation for configuration objects
    virtual function void do_copy(uvm_object rhs);
        apb_slave_config rhs_;
        if (!$cast(rhs_, rhs)) return;
        super.do_copy(rhs);
        this.is_active      = rhs_.is_active;
        this.has_coverage   = rhs_.has_coverage;
        this.has_scoreboard = rhs_.has_scoreboard;
    endfunction

    // Configuration comparison implementation
    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        apb_slave_config rhs_;
        bit status = 1;
        if (!$cast(rhs_, rhs)) return 0;
        void'(super.do_compare(rhs, comparer));
        if (this.is_active!= rhs_.is_active) status = 0;
        if (this.has_coverage!= rhs_.has_coverage) status = 0;
        if (this.has_scoreboard!= rhs_.has_scoreboard) status = 0;
        return status;
    endfunction

    // Formatted print implementation for debugging
    virtual function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_string("is_active", this.is_active.name());
        printer.print_field("has_coverage", this.has_coverage, 1, UVM_BIN);
        printer.print_field("has_scoreboard", this.has_scoreboard, 1, UVM_BIN);
    endfunction
endclass

`endif
