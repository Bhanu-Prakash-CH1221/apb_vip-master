//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_master_read_seq.svh
// Description  : Read-only sequence for master agent
// Author       : CH Bhanu Prakash
// Notes        : Generates read-only transactions for APB testing
//-----------------------------------------------------------------------------

`ifndef _APB_MASTER_READ_SEQ_
`define _APB_MASTER_READ_SEQ_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_master_pkg::*;

class apb_master_read_seq extends uvm_sequence#(apb_master_seq_item);
  int unsigned num_transactions = 10;  // Number of read transactions to generate
  
  // UVM factory registration for sequence creation
  typedef uvm_object_registry#(apb_master_read_seq, "apb_master_read_seq") type_id;
  static function type_id get_type(); 
    return type_id::get(); 
  endfunction
  virtual function uvm_object_wrapper get_object_type(); 
    return type_id::get(); 
  endfunction
  virtual function string get_type_name(); 
    return "apb_master_read_seq"; 
  endfunction
  virtual function uvm_object create(string name="");
    apb_master_read_seq tmp = new(name); 
    return tmp;
  endfunction 
  
  function new(string name = "apb_master_read_seq");
    super.new(name);
  endfunction
  
  task body();
    apb_master_seq_item m_apb_seq_item;
    repeat(num_transactions) begin
      // Create new sequence item for each transaction
      m_apb_seq_item = apb_master_seq_item::type_id::create("m_apb_seq_item");
      
      // Start transaction and randomize fields
      start_item(m_apb_seq_item);
      void'(m_apb_seq_item.randomize());
      
      // Force transaction type to READ
      m_apb_seq_item.apb_tr = apb_base_seq_item::READ;
      
      // Send transaction to driver
      finish_item(m_apb_seq_item);
    end
  endtask
endclass

`endif