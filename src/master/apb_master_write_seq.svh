`ifndef _APB_MASTER_WRITE_SEQ_
`define _APB_MASTER_WRITE_SEQ_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_master_pkg::*;

class apb_master_write_seq extends uvm_sequence#(apb_master_seq_item);
  int unsigned num_transactions = 10;
  
  // Manual Factory Registration - Eliminates Macro Branches
  typedef uvm_object_registry#(apb_master_write_seq, "apb_master_write_seq") type_id;
  static function type_id get_type(); return type_id::get(); endfunction
  virtual function uvm_object_wrapper get_object_type(); return type_id::get(); endfunction
  virtual function string get_type_name(); return "apb_master_write_seq"; endfunction
  virtual function uvm_object create(string name="");
    apb_master_write_seq tmp = new(name); return tmp;
  endfunction 
  
  function new(string name = "apb_master_write_seq");
    super.new(name);
  endfunction
  
  task body();
    apb_master_seq_item m_apb_seq_item;
    repeat(num_transactions) begin
      m_apb_seq_item = apb_master_seq_item::type_id::create("m_apb_seq_item");
      start_item(m_apb_seq_item);
      // randomization always succeeds with proper constraints
      void'(m_apb_seq_item.randomize());
      m_apb_seq_item.apb_tr = apb_base_seq_item::WRITE;
      finish_item(m_apb_seq_item);
    end
  endtask
endclass

`endif