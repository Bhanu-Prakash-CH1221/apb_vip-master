`ifndef _APB_FIELD_AUTO_TEST_
`define _APB_FIELD_AUTO_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_field_auto_test extends uvm_test;
  typedef uvm_component_registry#(apb_field_auto_test, "apb_field_auto_test") type_id;
  static function type_id get_type(); return type_id::get(); endfunction
  virtual function uvm_object_wrapper get_object_type(); return type_id::get(); endfunction
  virtual function string get_type_name(); return "apb_field_auto_test"; endfunction

  apb_env env;
  apb_master_config m_apb_master_config;
  apb_slave_config m_apb_slave_config;

  function new(string name = "apb_field_auto_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
    m_apb_slave_config = apb_slave_config::type_id::create("m_apb_slave_config");
    uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
    uvm_config_db#(apb_slave_config)::set(null, "*", "apb_slave_config", m_apb_slave_config);
    env = apb_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Provide explicit permutations to cleanly clear the $cast branch misses 
    // and manual comparison branch logic embedded in the data objects.
    begin
      apb_base_seq_item b1 = new, b2 = new;
      apb_master_config m1 = new, m2 = new;
      apb_slave_config s1 = new, s2 = new;
      apb_master_seq_item ms1 = new, ms2 = new;
      apb_slave_seq_item ss1 = new, ss2 = new;

      // 1. Force do_copy $cast failures
      b1.do_copy(m1); m1.do_copy(s1); s1.do_copy(b1);
      ms1.do_copy(s1); ss1.do_copy(m1);

      // 2. Force do_compare $cast failures
      void'(b1.do_compare(m1, uvm_default_comparer));
      void'(m1.do_compare(s1, uvm_default_comparer));
      void'(s1.do_compare(b1, uvm_default_comparer));
      void'(ms1.do_compare(s1, uvm_default_comparer));
      void'(ss1.do_compare(m1, uvm_default_comparer));

      // 3. Force explicit field mismatch comparisons
      b1.addr = 1; b2.addr = 2; void'(b1.do_compare(b2, uvm_default_comparer)); b2.addr = 1;
      b1.data = 1; b2.data = 2; void'(b1.do_compare(b2, uvm_default_comparer)); b2.data = 1;
      b1.delay = 1; b2.delay = 2; void'(b1.do_compare(b2, uvm_default_comparer)); b2.delay = 1;
      b1.apb_tr = apb_base_seq_item::READ; b2.apb_tr = apb_base_seq_item::WRITE; void'(b1.do_compare(b2, uvm_default_comparer)); b2.apb_tr = b1.apb_tr;

      m1.is_active = apb_master_config::UVM_ACTIVE; m2.is_active = apb_master_config::UVM_PASSIVE; void'(m1.do_compare(m2, uvm_default_comparer)); m2.is_active = m1.is_active;
      m1.has_coverage = 0; m2.has_coverage = 1; void'(m1.do_compare(m2, uvm_default_comparer)); m2.has_coverage = m1.has_coverage;
      m1.has_scoreboard = 0; m2.has_scoreboard = 1; void'(m1.do_compare(m2, uvm_default_comparer)); m2.has_scoreboard = m1.has_scoreboard;

      s1.is_active = apb_slave_config::UVM_ACTIVE; s2.is_active = apb_slave_config::UVM_PASSIVE; void'(s1.do_compare(s2, uvm_default_comparer)); s2.is_active = s1.is_active;
      s1.has_coverage = 0; s2.has_coverage = 1; void'(s1.do_compare(s2, uvm_default_comparer)); s2.has_coverage = s1.has_coverage;
      s1.has_scoreboard = 0; s2.has_scoreboard = 1; void'(s1.do_compare(s2, uvm_default_comparer)); s2.has_scoreboard = s1.has_scoreboard;
    end

    #100ns;
    phase.drop_objection(this);
  endtask
endclass
`endif
