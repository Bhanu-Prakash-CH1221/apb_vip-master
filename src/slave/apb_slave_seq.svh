//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_seq.svh
// Description  : Slave response sequence class
// Author       : CH Bhanu Prakash
// Notes        : Generates slave response transactions for APB testing
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_SEQ_
`define _APB_SLAVE_SEQ_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;

class apb_slave_seq extends uvm_sequence#(apb_slave_seq_item);
  int unsigned num_transactions = 10;  // Number of response transactions to generate
  
  // UVM factory registration for slave sequence
  typedef uvm_object_registry#(apb_slave_seq, "apb_slave_seq") type_id;
  static function type_id get_type(); 
    return type_id::get(); 
  endfunction
  virtual function uvm_object_wrapper get_object_type(); 
    return type_id::get(); 
  endfunction
  virtual function string get_type_name(); 
    return "apb_slave_seq"; 
  endfunction
  virtual function uvm_object create(string name="");
    apb_slave_seq tmp = new(name); 
    return tmp;
  endfunction 
  
  function new(string name = "apb_slave_seq");
    super.new(name);
  endfunction
  
  // Generate alternating read/write response transactions
  task body();
    apb_slave_seq_item m_apb_seq_item;
    static int txn_count = 0;  // Transaction counter for alternating pattern
    
    repeat(num_transactions) begin
      // Create new sequence item for each response
      m_apb_seq_item = apb_slave_seq_item::type_id::create("m_apb_seq_item");
      start_item(m_apb_seq_item);
      
      // Alternate between read and write responses
      if (txn_count % 2 == 0) begin
        m_apb_seq_item.apb_tr = apb_base_seq_item::WRITE;  // Write response
        m_apb_seq_item.data   = 32'h0000_0000;            // Zero data for write
      end else begin
        m_apb_seq_item.apb_tr = apb_base_seq_item::READ;   // Read response
        m_apb_seq_item.data   = 32'hDEAD_BEEF;              // Known pattern for read data
      end
      
      txn_count++;                    // Increment transaction counter
      m_apb_seq_item.delay = 1;       // Set fixed delay
      void'(m_apb_seq_item.randomize());  // Randomize other fields
      finish_item(m_apb_seq_item);    // Send response to driver
    end
  endtask
endclass

`endif