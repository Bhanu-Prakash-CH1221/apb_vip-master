`ifndef _APB_MASTER_MONITOR_
`define _APB_MASTER_MONITOR_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_master_monitor extends uvm_monitor;
    `uvm_component_utils(apb_master_monitor)

    virtual apb_if                        vif;
    uvm_analysis_port#(apb_base_seq_item) ap;
    apb_coverage                          apb_cov;

    extern function new(string name, uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task           run_phase(uvm_phase phase);
endclass

function apb_master_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
    ap      = new("ap", this);
    // FIX 1: Removed apb_cov creation from here. 
    // If created here, factory tests that call new() but never run build_phase() 
    // will leave empty covergroups that drag down the merged coverage score.
endfunction

function void apb_master_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Master monitor: virtual interface obtained");
    
    // FIX 1: Moved coverage instantiation to build_phase.
    // This ensures coverage is only collected for components actually participating in the simulation.
    apb_cov = apb_coverage::type_id::create("apb_cov", this);
    
    uvm_config_db#(apb_coverage)::set(this, "", "coverage", apb_cov);
    $display("Master monitor: coverage registered");
endfunction

task apb_master_monitor::run_phase(uvm_phase phase);
    $display("Master monitor starting");
    fork
        forever begin
            @(posedge vif.PCLK);
            apb_cov.psel   = vif.PSEL;
            apb_cov.penable = vif.PENABLE;
            apb_cov.pwrite  = vif.PWRITE;
            apb_cov.pready  = vif.PREADY;
            apb_cov.tr_type = vif.PWRITE;

            // FEC FIX: Replace if-else chain with case statement.
            // Original "else if (PSEL && !PENABLE)" had an unreachable FEC
            // condition: PENABLE=1 making !PENABLE=0 while this else-if is
            // evaluated — impossible because PSEL=1,PENABLE=1 is caught by the
            // FIRST condition.  The case statement has no compound booleans.
            case ({vif.PSEL, vif.PENABLE})
                2'b11:   apb_cov.protocol_phase = 2;  // ACCESS
                2'b10:   apb_cov.protocol_phase = 1;  // SETUP
                default: apb_cov.protocol_phase = 0;  // IDLE (or UNKNOWN)
            endcase
            apb_cov.sample_protocol_state();
        end
        forever begin
            apb_base_seq_item tr;
            $display("Master monitor: waiting for PSEL");
            wait(vif.PSEL === 1'b1);
            $display($sformatf("Master monitor: PSEL detected PADDR=%0h PWRITE=%0b",
                vif.PADDR, vif.PWRITE));
            tr        = apb_base_seq_item::type_id::create("tr", this);
            tr.apb_tr = vif.PWRITE ? apb_base_seq_item::WRITE : apb_base_seq_item::READ;
            tr.addr   = vif.PADDR;
            tr.delay  = 1;
            $display("Master monitor: waiting for PENABLE+PREADY");
            @(posedge vif.PCLK);
            wait(vif.PENABLE === 1'b1 && vif.PREADY === 1'b1);
            if (vif.PWRITE) begin
                tr.data = vif.PWDATA;
                $display("Master monitor: captured WRITE data");
            end else begin
                tr.data = vif.PRDATA;
                $display("Master monitor: captured READ data");
            end
            $display($sformatf("Master monitor: captured %s", tr.convert2string()));
            wait(vif.PENABLE === 1'b0);
            $display($psprintf("%s", tr.convert2string()));
            apb_cov.write(tr);
            ap.write(tr);
            $display("Master monitor: transaction sent to scoreboard");
        end
    join
endtask

`endif
