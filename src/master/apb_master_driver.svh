//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_master_driver.svh
// Description  : Master driver component for APB protocol
// Author       : CH Bhanu Prakash
// Notes        : Drives master-side APB protocol signals
//-----------------------------------------------------------------------------

`ifndef _APB_MASTER_DRIVER_
`define _APB_MASTER_DRIVER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_master_driver extends uvm_driver#(apb_master_seq_item);
    `uvm_component_utils(apb_master_driver)

    // Driver components
    virtual apb_if      vif;              // Virtual interface to DUT
    apb_master_seq_item m_apb_seq_item;   // Current sequence item
    apb_coverage        apb_cov;          // Coverage collector

    extern function new(string name = "apb_master_driver", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task           run_phase(uvm_phase phase);
    extern virtual task           wait_for_reset();
    extern virtual task           get_and_drive();
    extern virtual task           init_signals();
endclass

function apb_master_driver::new(string name = "apb_master_driver", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Initialize factory methods for UVM component creation
    void'(get_object_type());
    void'(get_type_name());

    // Get virtual interface from config database
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Master driver: virtual interface obtained");
    
    // Create coverage collector and share with other components
    apb_cov = apb_coverage::type_id::create("apb_cov", this);
    uvm_config_db#(apb_coverage)::set(this, "", "apb_cov", apb_cov);
    $display("Master driver: coverage instance created");
endfunction

task apb_master_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    init_signals();      // Initialize all signals to safe state
    wait_for_reset();    // Wait for reset deassertion
    get_and_drive();     // Start driving transactions
endtask

task apb_master_driver::get_and_drive();
    $display("Master driver starting get_and_drive");
    forever begin
        $display("Waiting for sequence item");
        m_apb_seq_item = apb_master_seq_item::type_id::create("m_apb_seq_item", this);
        seq_item_port.get_next_item(m_apb_seq_item);
        $display($sformatf("Got item: %s", m_apb_seq_item.convert2string()));

        // Sample coverage for this transaction
        apb_cov.write(m_apb_seq_item);

        // Apply inter-transaction delay
        repeat(m_apb_seq_item.delay)
            @(posedge vif.PCLK);

        $display($sformatf("Driving: addr=%0h data=%0h write=%0b",
            m_apb_seq_item.addr, m_apb_seq_item.data, m_apb_seq_item.apb_tr));

        // Start APB transaction - SETUP phase
        vif.PSEL   <= 1'b1;  // Assert select
        vif.PADDR  <= m_apb_seq_item.addr;  // Drive address
        vif.PWRITE <= (m_apb_seq_item.apb_tr == apb_base_seq_item::WRITE) ? 1'b1 : 1'b0;  // Set direction

        // Set write data for write transactions
        if (m_apb_seq_item.apb_tr == apb_base_seq_item::WRITE) begin
            vif.PWDATA <= m_apb_seq_item.data;  // Drive write data
            $display("WRITE transaction: PWDATA set");
        end else begin
            vif.PWDATA <= '0;  // Clear for read transactions
            $display("READ transaction: PWDATA cleared");
        end

        // Move to ACCESS phase
        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b1;  // Assert enable
        wait(vif.PREADY);     // Wait for slave ready

        // Complete transaction - return to IDLE
        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b0;  // Deassert select
        vif.PENABLE <= 1'b0;  // Deassert enable

        // Sample protocol coverage for transaction completion
        apb_cov.psel           = 1'b0;
        apb_cov.penable        = 1'b0;
        apb_cov.pwrite         = (m_apb_seq_item.apb_tr == apb_base_seq_item::WRITE) ? 1'b1 : 1'b0;
        apb_cov.protocol_phase = 0;  // IDLE phase
        apb_cov.sample_protocol_state();

        $display($psprintf(" %s", m_apb_seq_item.convert2string()));
        seq_item_port.item_done();  // Notify sequencer of completion
        $display("Transaction completed");
    end
endtask

task apb_master_driver::wait_for_reset();
    // Wait for reset assertion
    @(negedge vif.PRESET_N);
    $display("Reset asserted - holding signals");
    
    // Drive all signals to safe state during reset
    vif.PSEL    <= 1'b0;
    vif.PWRITE  <= 1'b0;
    vif.PENABLE <= 1'b0;
    vif.PWDATA  <= '0;
    vif.PADDR   <= '0;
    
    // Wait for reset deassertion
    @(posedge vif.PRESET_N);
    $display("Reset released - ready to drive");
endtask

task apb_master_driver::init_signals();
    // Initialize all APB signals to safe idle state
    vif.PSEL    <= 1'b0;  // Peripheral not selected
    vif.PWRITE  <= 1'b0;  // Read direction
    vif.PENABLE <= 1'b0;  // Protocol not enabled
    vif.PWDATA  <= '0;   // No write data
    vif.PADDR   <= '0;   // Zero address
endtask

`endif
