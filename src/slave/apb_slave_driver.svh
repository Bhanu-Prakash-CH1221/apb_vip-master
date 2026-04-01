//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_slave_driver.svh
// Description  : Slave driver component for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Drives slave-side APB protocol signals and responses
//-----------------------------------------------------------------------------

`ifndef _APB_SLAVE_DRIVER_
`define _APB_SLAVE_DRIVER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_slave_driver extends uvm_driver#(apb_slave_seq_item);
    `uvm_component_utils(apb_slave_driver)

    // Driver components
    virtual apb_if     vif;              // Virtual interface to DUT
    apb_slave_seq_item m_apb_seq_item;   // Current sequence item

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

    // Initialize factory methods for UVM component creation
    void'(get_object_type());
    void'(get_type_name());

    // Get virtual interface from config database
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Slave driver: virtual interface obtained");
endfunction

task apb_slave_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    init_signals();      // Initialize all signals to safe state
    wait_for_reset();    // Wait for reset deassertion
    get_and_drive();     // Start responding to transactions
endtask

task apb_slave_driver::get_and_drive();
    $display("Slave driver starting get_and_drive");
    forever begin
        // Get next response item from sequencer
        m_apb_seq_item = apb_slave_seq_item::type_id::create("m_apb_seq_item", this);
        seq_item_port.get_next_item(m_apb_seq_item);
        $display($sformatf("Slave driver: got item %s", m_apb_seq_item.convert2string()));

        // Wait for SETUP phase (PSEL=1, PENABLE=0)
        wait(vif.PSEL == 1'b1 && vif.PENABLE == 1'b0);
        $display("Slave driver: SETUP phase detected");

        // Wait for ACCESS phase (PENABLE=1)
        @(posedge vif.PCLK);
        wait(vif.PENABLE == 1'b1);
        $display("Slave driver: ACCESS phase detected, PREADY=0 for 1 wait cycle");

        // Insert wait cycle by deasserting PREADY
        vif.PREADY <= 1'b0;
        @(posedge vif.PCLK);
        vif.PREADY <= 1'b1;  // Assert ready for next cycle
        $display("Slave driver: PREADY asserted");

        // Provide response based on transaction type
        if (vif.PWRITE == 1'b0) begin
            vif.PRDATA <= m_apb_seq_item.data;  // Drive read data
            $display($sformatf("Slave driver: READ response PRDATA=0x%0h", m_apb_seq_item.data));
        end else begin
            vif.PRDATA <= '0;  // Clear data for write transactions
            $display("Slave driver: WRITE acknowledgment");
        end

        // Wait for transaction completion
        @(posedge vif.PCLK);
        wait(vif.PENABLE == 1'b0);  // Wait for PENABLE deassertion
        $display("Slave driver: PENABLE low - completing");
        vif.PREADY <= 1'b0;  // Deassert ready

        seq_item_port.item_done();  // Notify sequencer of completion
        $display("Slave driver: transaction completed");
    end
endtask

task apb_slave_driver::wait_for_reset();
    // Wait for reset assertion
    @(negedge vif.PRESET_N);
    $display("Slave driver: reset asserted");
    
    // Drive signals to safe state during reset
    vif.PREADY <= 1'b0;
    vif.PRDATA <= '0;
    
    // Wait for reset deassertion
    @(posedge vif.PRESET_N);
    $display("Slave driver: reset released");
endtask

task apb_slave_driver::init_signals();
    // Initialize slave signals to safe idle state
    vif.PREADY <= 1'b0;  // Not ready initially
    vif.PRDATA <= '0;   // No read data
endtask

`endif
