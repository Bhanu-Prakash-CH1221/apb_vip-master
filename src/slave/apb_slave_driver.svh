`ifndef _APB_SLAVE_DRIVER_
`define _APB_SLAVE_DRIVER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_driver extends uvm_driver#(apb_slave_seq_item);
    `uvm_component_utils(apb_slave_driver)

    virtual apb_if     vif;
    apb_slave_seq_item m_apb_seq_item;

    extern function new(string name = "apb_slave_driver", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task           run_phase(uvm_phase phase);
    extern virtual task           wait_for_reset();
    extern virtual task           get_and_drive();
    extern virtual task           init_signals();
endclass

function apb_slave_driver::new(string name = "apb_slave_driver", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Slave driver: virtual interface obtained");
endfunction

task apb_slave_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    init_signals();
    wait_for_reset();
    get_and_drive();
endtask

task apb_slave_driver::get_and_drive();
    $display("Slave driver starting get_and_drive");
    forever begin
        m_apb_seq_item = apb_slave_seq_item::type_id::create("m_apb_seq_item", this);
        seq_item_port.get_next_item(m_apb_seq_item);
        $display($sformatf("Slave driver: got item %s", m_apb_seq_item.convert2string()));

        wait(vif.PSEL == 1'b1 && vif.PENABLE == 1'b0);
        $display("Slave driver: SETUP phase detected");

        @(posedge vif.PCLK);
        wait(vif.PENABLE == 1'b1);
        $display("Slave driver: ACCESS phase detected, PREADY=0 for 1 wait cycle");

        // FEC FIX: Hold PREADY=0 for exactly one clock in ACCESS phase.
        // This makes APB_master.sv see PSEL=1, PENABLE=1, PREADY=0 for one
        // clock, hitting the previously-unreachable PREADY_0 FEC condition in
        // both the write-counter and read-counter conditions.
        vif.PREADY <= 1'b0;
        @(posedge vif.PCLK);  // wait-state clock with PREADY=0
        vif.PREADY <= 1'b1;   // now assert PREADY (transfer completes)
        $display("Slave driver: PREADY asserted");

        // Branch TRUE : READ  (both arms hit across mixed transaction sequences)
        // Branch FALSE: WRITE
        if (vif.PWRITE == 1'b0) begin
            vif.PRDATA <= m_apb_seq_item.data;
            $display($sformatf("Slave driver: READ response PRDATA=0x%0h", m_apb_seq_item.data));
        end else begin
            vif.PRDATA <= '0;
            $display("Slave driver: WRITE acknowledgment");
        end

        @(posedge vif.PCLK);
        wait(vif.PENABLE == 1'b0);
        $display("Slave driver: PENABLE low - completing");
        vif.PREADY <= 1'b0;

        seq_item_port.item_done();
        $display("Slave driver: transaction completed");
    end
endtask

task apb_slave_driver::wait_for_reset();
    @(negedge vif.PRESET_N);
    $display("Slave driver: reset asserted");
    vif.PREADY <= 1'b0;
    vif.PRDATA <= '0;
    @(posedge vif.PRESET_N);
    $display("Slave driver: reset released");
endtask

task apb_slave_driver::init_signals();
    vif.PREADY <= 1'b0;
    vif.PRDATA <= '0;
endtask

`endif
