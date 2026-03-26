`ifndef _APB_UVM_MACRO_TEST_
`define _APB_UVM_MACRO_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_uvm_macro_test extends uvm_test;
  typedef uvm_component_registry#(apb_uvm_macro_test, "apb_uvm_macro_test") type_id;
  static function type_id get_type(); return type_id::get(); endfunction
  virtual function uvm_object_wrapper get_object_type(); return type_id::get(); endfunction
  virtual function string get_type_name(); return "apb_uvm_macro_test"; endfunction

  apb_env env;
  apb_master_config m_apb_master_config;
  apb_slave_config m_apb_slave_config;
  virtual apb_if vif;

  function new(string name = "apb_uvm_macro_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
    m_apb_slave_config = apb_slave_config::type_id::create("m_apb_slave_config");
    uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
    uvm_config_db#(apb_slave_config)::set(null, "*", "apb_slave_config", m_apb_slave_config);
    env = apb_env::type_id::create("env", this);
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // Exercise hardware UNKNOWN branch and phase decoding safely
    @(posedge vif.PCLK);
    vif.PSEL <= 1'b0; vif.PENABLE <= 1'b0;
    @(posedge vif.PCLK);
    vif.PSEL <= 1'b0; vif.PENABLE <= 1'b1;
    @(posedge vif.PCLK);
    vif.PENABLE <= 1'b0;
    @(posedge vif.PCLK);
    
    // Also drive protocol_error toggles multiple times
    // This will be captured by the DUT's protocol_error output
    repeat(5) begin
        @(posedge vif.PCLK);
        vif.PSEL <= 1'b0; vif.PENABLE <= 1'b1;
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b0;
        @(posedge vif.PCLK);
    end
    
    phase.drop_objection(this);
  endtask
endclass
`endif
