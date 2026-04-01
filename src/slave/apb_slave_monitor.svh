//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_monitor.svh
// Description  : Slave monitor component for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Monitors slave-side responses and protocol compliance
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_MONITOR_
`define _APB_SLAVE_MONITOR_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_monitor extends uvm_monitor;
    `uvm_component_utils(apb_slave_monitor)

    // Monitor components
    virtual apb_if                        vif;  // Virtual interface to DUT
    uvm_analysis_port#(apb_base_seq_item) ap;   // Analysis port to scoreboard
    apb_coverage                          apb_cov;  // Coverage collector

    extern function new(string name, uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task           run_phase(uvm_phase phase);
endclass

function apb_slave_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
    ap      = new("ap", this);  // Create analysis port for transaction broadcasting
endfunction

function void apb_slave_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Initialize factory methods for UVM component creation
    void'(get_object_type());
    void'(get_type_name());

    // Get virtual interface from config database
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Slave monitor: virtual interface obtained");
    
    // Create coverage collector and share with other components
    apb_cov = apb_coverage::type_id::create("apb_cov", this);
    
    uvm_config_db#(apb_coverage)::set(this, "", "coverage", apb_cov);
    $display("Slave monitor: coverage registered");
endfunction

task apb_slave_monitor::run_phase(uvm_phase phase);
    $display("Slave monitor starting");
    fork
        // Protocol state monitoring thread
        forever begin
            @(posedge vif.PCLK);
            apb_cov.psel    = vif.PSEL;
            apb_cov.penable = vif.PENABLE;
            apb_cov.pwrite  = vif.PWRITE;
            apb_cov.pready  = vif.PREADY;
            apb_cov.tr_type = vif.PWRITE;
            // Determine protocol phase for coverage
            case ({vif.PSEL, vif.PENABLE})
                2'b11:   apb_cov.protocol_phase = 2;  // ACCESS phase
                2'b10:   apb_cov.protocol_phase = 1;  // SETUP phase
                default: apb_cov.protocol_phase = 0;  // IDLE phase
            endcase
            apb_cov.sample_protocol_state();
        end
        // Transaction capture thread
        forever begin
            apb_base_seq_item tr;
            $display("Slave monitor: waiting for PSEL");
            wait(vif.PSEL === 1'b1);  // Wait for transaction start
            
            $display($sformatf("Slave monitor: PSEL detected PADDR=%0h PWRITE=%0b",
                vif.PADDR, vif.PWRITE));
                
            // Create and populate transaction object
            tr        = apb_base_seq_item::type_id::create("tr", this);
            tr.apb_tr = vif.PWRITE ? apb_base_seq_item::WRITE : apb_base_seq_item::READ;
            tr.addr   = vif.PADDR;
            tr.delay  = 1;
            
            $display("Slave monitor: waiting for PENABLE+PREADY");
            @(posedge vif.PCLK);
            wait(vif.PENABLE === 1'b1 && vif.PREADY === 1'b1);  // Wait for data phase
            
            // Capture data based on transaction type
            if (vif.PWRITE) begin
                tr.data = vif.PWDATA;  // Capture write data
                $display("Slave monitor: captured WRITE data");
            end else begin
                tr.data = vif.PRDATA;  // Capture read data
                $display("Slave monitor: captured READ data");
            end
            
            $display($sformatf("Slave monitor: captured %s", tr.convert2string()));
            wait(vif.PENABLE === 1'b0);  // Wait for transaction completion
            
            $display($psprintf("%s", tr.convert2string()));
            apb_cov.write(tr);  // Sample coverage
            ap.write(tr);       // Send to scoreboard
            $display("Slave monitor: transaction sent to scoreboard");
        end
    join
endtask

`endif
