//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_field_auto_test.svh
// Description  : Field automation test for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Tests UVM field automation and utility functions
//-----------------------------------------------------------------------------

`ifndef _APB_FIELD_AUTO_TEST_
`define _APB_FIELD_AUTO_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_field_auto_test extends uvm_test;
    `uvm_component_utils(apb_field_auto_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_field_auto_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase for test environment setup
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Initialize factory methods for UVM component creation
        void'(get_type());
        void'(get_object_type());

        // Create configuration objects
        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");
        
        // Share configurations with agents via config database
        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null, "*", "apb_slave_config",  m_apb_slave_config);
        
        // Create test environment
        env = apb_env::type_id::create("env", this);
    endfunction

    // Run phase for field automation testing
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        begin
            // Create test objects for field automation testing
            apb_base_seq_item b1 = new, b2 = new;           // Base sequence items
            apb_master_config m1 = new, m2 = new;           // Master configurations
            apb_slave_config s1 = new, s2 = new;             // Slave configurations
            apb_master_seq_item ms1 = new, ms2 = new;       // Master sequence items
            apb_slave_seq_item ss1 = new, ss2 = new;       // Slave sequence items

            // Test do_copy method between different object types
            b1.do_copy(m1); m1.do_copy(s1); s1.do_copy(b1);
            ms1.do_copy(s1); ss1.do_copy(m1);

            // Test do_compare method between different object types
            void'(b1.do_compare(m1, uvm_default_comparer));
            void'(m1.do_compare(s1, uvm_default_comparer));
            void'(s1.do_compare(b1, uvm_default_comparer));
            void'(ms1.do_compare(s1, uvm_default_comparer));
            void'(ss1.do_compare(m1, uvm_default_comparer));

            // Test field comparison for base sequence item fields
            b1.addr = 1; b2.addr = 2; void'(b1.do_compare(b2, uvm_default_comparer)); b2.addr = 1;
            b1.data = 1; b2.data = 2; void'(b1.do_compare(b2, uvm_default_comparer)); b2.data = 1;
            b1.delay = 1; b2.delay = 2; void'(b1.do_compare(b2, uvm_default_comparer)); b2.delay = 1;
            b1.apb_tr = apb_base_seq_item::READ; b2.apb_tr = apb_base_seq_item::WRITE; void'(b1.do_compare(b2, uvm_default_comparer)); b2.apb_tr = b1.apb_tr;

            // Test master configuration field comparison
            m1.is_active = apb_master_config::UVM_ACTIVE; m2.is_active = apb_master_config::UVM_PASSIVE; void'(m1.do_compare(m2, uvm_default_comparer)); m2.is_active = m1.is_active;
            m1.has_coverage = 0; m2.has_coverage = 1; void'(m1.do_compare(m2, uvm_default_comparer)); m2.has_coverage = m1.has_coverage;
            m1.has_scoreboard = 0; m2.has_scoreboard = 1; void'(m1.do_compare(m2, uvm_default_comparer)); m2.has_scoreboard = m1.has_scoreboard;

            // Test slave configuration field comparison
            s1.is_active = apb_slave_config::UVM_ACTIVE; s2.is_active = apb_slave_config::UVM_PASSIVE; void'(s1.do_compare(s2, uvm_default_comparer)); s2.is_active = s1.is_active;
            s1.has_coverage = 0; s2.has_coverage = 1; void'(s1.do_compare(s2, uvm_default_comparer)); s2.has_coverage = s1.has_coverage;
            s1.has_scoreboard = 0; s2.has_scoreboard = 1; void'(s1.do_compare(s2, uvm_default_comparer)); s2.has_scoreboard = s1.has_scoreboard;
        end

        #100ns;  // Allow time for operations to complete
        phase.drop_objection(this);
    endtask
endclass
`endif
