`ifndef _APB_MASTER_SEQ_ITEM_
`define _APB_MASTER_SEQ_ITEM_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;

class apb_master_seq_item extends apb_base_seq_item;
  // Manual Factory Registration - Eliminates Macro Branches
  typedef uvm_object_registry#(apb_master_seq_item, "apb_master_seq_item") type_id;
  static function type_id get_type(); return type_id::get(); endfunction
  virtual function uvm_object_wrapper get_object_type(); return type_id::get(); endfunction
  virtual function string get_type_name(); return "apb_master_seq_item"; endfunction
  virtual function uvm_object create(string name="");
    apb_master_seq_item tmp = new(name); return tmp;
  endfunction

  function new(string name = "apb_master_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("\n-------------------------APB_MASTER_TRANSFER-------------------------\nDIR.=%s\nADDR=%0h\nDATA=%0h\n--------------------------------------------------------------", apb_tr, addr, data);
  endfunction
endclass

`endif