//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_base_seq_item.svh
// Description  : Base transaction item class for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Common properties and utilities for all APB transactions
//-----------------------------------------------------------------------------

`ifndef _APB_BASE_SEQ_ITEM_
`define _APB_BASE_SEQ_ITEM_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_base_seq_item extends uvm_sequence_item;
  
  // Transaction direction enumeration
  typedef enum {READ, WRITE} apb_transfer_direction_t;

  // Randomizable transaction fields
  rand bit [31:0] addr;                    // Transaction address
  rand logic [31:0] data;                    // Transaction data
  rand int                            delay;           // Inter-transaction delay
  rand apb_transfer_direction_t       apb_tr;      // Transfer direction

  // UVM factory registration for object creation
  typedef uvm_object_registry#(apb_base_seq_item, "apb_base_seq_item") type_id;
  static function type_id get_type(); return type_id::get(); endfunction
  virtual function uvm_object_wrapper get_object_type(); return type_id::get(); endfunction
  virtual function string get_type_name(); return "apb_base_seq_item"; endfunction
  virtual function uvm_object create(string name="");
    apb_base_seq_item tmp = new(name); return tmp;
  endfunction

  // Address constraint for comprehensive coverage
  constraint c_addr {
    addr dist {
      [32'h00000000 : 32'h0000FFFF] := 40,  // Low address range
      [32'h00010000 : 32'h7FFFFFFF] := 30,  // Mid address range
      [32'h80000000 : 32'hFFFFFFFF] := 30   // High address range
    };
  };

  // Data constraint for comprehensive coverage
  constraint c_data {
    data dist {
      32'h00000000                := 20,  // All zeros
      32'hFFFFFFFF                := 20,  // All ones
      32'hAAAAAAAA                := 20,  // Alternating pattern
      [32'h00000001:32'hFFFFFFFE] := 40   // Random range
    };
  };

  // Delay constraint for timing scenarios
  constraint c_delay {
    delay dist {
      1      := 25,
      2      := 25,
      [3:10] := 50
    };
  };

  function new(string name = "apb_base_seq_item");
    super.new(name);
  endfunction

  // Deep copy implementation for transaction objects
  virtual function void do_copy(uvm_object rhs);
    apb_base_seq_item rhs_;
    if (!$cast(rhs_, rhs)) return;
    super.do_copy(rhs); 
    this.addr   = rhs_.addr;
    this.data   = rhs_.data;
    this.delay  = rhs_.delay;
    this.apb_tr = rhs_.apb_tr;
  endfunction

  // Transaction comparison implementation
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    apb_base_seq_item rhs_;
    bit status = 1;

    if (!$cast(rhs_, rhs)) return 0;
    void'(super.do_compare(rhs, comparer));
    
    // Compare all transaction fields
    if (this.addr != rhs_.addr) status = 0;
    if (this.data != rhs_.data) status = 0;
    if (this.delay != rhs_.delay) status = 0;
    if (this.apb_tr != rhs_.apb_tr) begin
      comparer.print_msg($sformatf("apb_tr mismatch: %s!= %s", this.apb_tr.name(), rhs_.apb_tr.name()));
      status = 0;
    end

    return status;
  endfunction

  // Formatted print implementation for debugging
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("addr", this.addr, $bits(this.addr), UVM_HEX);
    printer.print_field("data", this.data, $bits(this.data), UVM_HEX);
    printer.print_field("delay", this.delay, $bits(this.delay), UVM_DEC);
    printer.print_string("apb_tr", this.apb_tr.name());
  endfunction

  // String conversion for transaction display
  virtual function string convert2string();
    return $sformatf("\n-------------------------APB_BASE_TRANSFER-------------------------\nDIR.=%s\nADDR=%0h\nDATA=%0h\n--------------------------------------------------------------", apb_tr, addr, data);
  endfunction

endclass

`endif