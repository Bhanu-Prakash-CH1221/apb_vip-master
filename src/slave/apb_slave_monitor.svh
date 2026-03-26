`ifndef _APB_SLAVE_MONITOR_
`define _APB_SLAVE_MONITOR_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_monitor extends uvm_monitor;
    `uvm_component_utils(apb_slave_monitor)

    virtual apb_if                        vif;
    uvm_analysis_port#(apb_base_seq_item) ap;
    apb_coverage                          apb_cov;

    extern function new(string name, uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task           run_phase(uvm_phase phase);
endclass

function apb_slave_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
    ap      = new("ap", this);
    // FIX 2: Removed apb_cov creation from here.
endfunction

function void apb_slave_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Slave monitor: virtual interface obtained");
    
    // FIX 2: Moved coverage instantiation to build_phase.
    apb_cov = apb_coverage::type_id::create("apb_cov", this);
    
    uvm_config_db#(apb_coverage)::set(this, "", "coverage", apb_cov);
    $display("Slave monitor: coverage registered");
endfunction

task apb_slave_monitor::run_phase(uvm_phase phase);
    $display("Slave monitor starting");
    fork
        forever begin
            @(posedge vif.PCLK);
            apb_cov.psel    = vif.PSEL;
            apb_cov.penable = vif.PENABLE;
            apb_cov.pwrite  = vif.PWRITE;
            apb_cov.pready  = vif.PREADY;
            apb_cov.tr_type = vif.PWRITE;
            // FEC FIX: case statement (same reason as master_monitor)
            case ({vif.PSEL, vif.PENABLE})
                2'b11:   apb_cov.protocol_phase = 2;
                2'b10:   apb_cov.protocol_phase = 1;
                default: apb_cov.protocol_phase = 0;
            endcase
            apb_cov.sample_protocol_state();
        end
        forever begin
            apb_base_seq_item tr;
            $display("Slave monitor: waiting for PSEL");
            wait(vif.PSEL === 1'b1);
            $display($sformatf("Slave monitor: PSEL detected PADDR=%0h PWRITE=%0b",
                vif.PADDR, vif.PWRITE));
            tr        = apb_base_seq_item::type_id::create("tr", this);
            tr.apb_tr = vif.PWRITE ? apb_base_seq_item::WRITE : apb_base_seq_item::READ;
            tr.addr   = vif.PADDR;
            tr.delay  = 1;
            $display("Slave monitor: waiting for PENABLE+PREADY");
            @(posedge vif.PCLK);
            wait(vif.PENABLE === 1'b1 && vif.PREADY === 1'b1);
            if (vif.PWRITE) begin
                tr.data = vif.PWDATA;
                $display("Slave monitor: captured WRITE data");
            end else begin
                tr.data = vif.PRDATA;
                $display("Slave monitor: captured READ data");
            end
            $display($sformatf("Slave monitor: captured %s", tr.convert2string()));
            wait(vif.PENABLE === 1'b0);
            $display($psprintf("%s", tr.convert2string()));
            apb_cov.write(tr);
            ap.write(tr);
            $display("Slave monitor: transaction sent to scoreboard");
        end
    join
endtask

`endif
