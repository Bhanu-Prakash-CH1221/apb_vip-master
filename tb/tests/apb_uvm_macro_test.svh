`ifndef _APB_UVM_MACRO_TEST_
`define _APB_UVM_MACRO_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_uvm_macro_test extends uvm_test;
    `uvm_component_utils(apb_uvm_macro_test)

    // Test components
    apb_env           env;                 // APB verification environment
    apb_master_config m_apb_master_config; // Master agent configuration
    apb_slave_config  m_apb_slave_config;  // Slave agent configuration
    virtual apb_if    vif;                 // Virtual interface to DUT

    function new(string name = "apb_uvm_macro_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

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
        
        // Get virtual interface from testbench
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    endfunction

    // Run phase - tests UVM macros and interface manipulation
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        // Test basic APB signal manipulation using UVM macros
        @(posedge vif.PCLK);
        vif.PSEL <= 1'b0; vif.PENABLE <= 1'b0;  // IDLE state
        @(posedge vif.PCLK);
        vif.PSEL <= 1'b0; vif.PENABLE <= 1'b1;  // Invalid state (PSEL=0, PENABLE=1)
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b0;                    // Return to IDLE
        @(posedge vif.PCLK);
        
        // Test repeated signal patterns
        repeat(5) begin
            @(posedge vif.PCLK);
            vif.PSEL <= 1'b0; vif.PENABLE <= 1'b1;  // Invalid state repeated
            @(posedge vif.PCLK);
            vif.PENABLE <= 1'b0;                    // Return to IDLE
            @(posedge vif.PCLK);
        end
    
        phase.drop_objection(this);
    endtask
endclass
`endif
