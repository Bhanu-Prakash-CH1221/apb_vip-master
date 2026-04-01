//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : testbench.sv
// Description  : Top-level testbench module with DUT instantiation
// Author       : CH Bhanu Prakash
// Notes        : Complete APB testbench with master and slave DUTs
//-----------------------------------------------------------------------------

`timescale 1ns/1ns

import uvm_pkg::*;
import apb_test_pkg::*;
import apb_common_pkg::*;

module testbench;

    // APB interface signals connecting to DUTs
    logic        pclk;           // Clock signal
    logic        presetn;         // Reset signal (active low)
    logic [31:0] paddr;          // Address bus
    logic        psel;           // Select signal
    logic        penable;        // Enable signal
    logic        pwrite;         // Write/read direction
    logic [31:0] prdata;         // Read data bus
    logic [31:0] pwdata;         // Write data bus
    logic        pready;         // Ready signal

    // Master DUT status signals
    logic [1:0]  master_apb_phase;    // Current APB phase
    logic [7:0]  master_write_count;    // Write transaction counter
    logic [7:0]  master_read_count;     // Read transaction counter
    logic        master_protocol_error; // Protocol error flag

    // Slave DUT status signals
    logic [31:0] slave_prdata_out;    // Slave read data output
    logic [7:0]  slave_write_count;     // Slave write counter
    logic [7:0]  slave_read_count;      // Slave read counter
    logic        slave_access_valid;    // Slave access validity flag

    // Clock generation
    initial begin
        pclk = 0;
    end

    // Reset sequence with proper timing
    initial begin
        presetn = 1;
        $display("Time: %0t, RESET: Initial presetn=1", $time);
        #200;  // Reset assertion time
        $display("Time: %0t, RESET: Applying reset presetn=0", $time);
        presetn = 0;
        #40;  // Reset hold time
        $display("Time: %0t, RESET: Releasing reset presetn=1", $time);
        presetn = 1;
    end

    always begin
        #10 pclk = ~pclk;
        if (!$test$plusargs("DISABLE_CLOCK_DEBUG")) begin
            $display("Time: %0t, CLOCK: pclk=%b, presetn=%b", $time, pclk, presetn);
        end
    end

    // Create APB interface instance
    apb_if apb_if_inst(pclk, presetn);

    // Connect interface signals to testbench level for monitoring
    assign paddr   = apb_if_inst.PADDR;
    assign psel    = apb_if_inst.PSEL;
    assign penable = apb_if_inst.PENABLE;
    assign pwrite  = apb_if_inst.PWRITE;
    assign prdata  = apb_if_inst.PRDATA;
    assign pwdata  = apb_if_inst.PWDATA;
    assign pready  = apb_if_inst.PREADY;

    // Instantiate Master DUT with APB bus connections
    APB_master u_apb_master (
        .PCLK           (pclk),           // Clock input
        .PRESET_N       (presetn),        // Reset input
        .PSEL           (psel),           // Select signal
        .PENABLE        (penable),         // Enable signal
        .PWRITE         (pwrite),         // Write/read direction
        .PREADY         (pready),         // Ready signal
        .PADDR          (paddr),          // Address bus
        .PWDATA         (pwdata),         // Write data bus
        .PRDATA         (prdata),         // Read data bus
        .apb_phase      (master_apb_phase), // Phase output
        .write_count    (master_write_count), // Write counter
        .read_count     (master_read_count),  // Read counter
        .protocol_error (master_protocol_error) // Protocol error
    );

    // Instantiate Slave DUT with APB bus connections
    APB_slave u_apb_slave (
        .PCLK        (pclk),           // Clock input
        .PRESET_N    (presetn),        // Reset input
        .PSEL        (psel),           // Select signal
        .PENABLE     (penable),         // Enable signal
        .PWRITE      (pwrite),         // Write/read direction
        .PADDR       (paddr),          // Address bus
        .PWDATA      (pwdata),         // Write data bus
        .PRDATA_out  (slave_prdata_out), // Read data output
        .write_count (slave_write_count), // Write counter
        .read_count  (slave_read_count),  // Read counter
        .access_valid(slave_access_valid) // Access validity flag
    );

    // Monitor and display APB protocol phase changes
    always @(posedge pclk) begin
        string phase_str;
        case ({psel, penable})
            2'b00: phase_str = "IDLE";    // No transaction in progress
            2'b10: phase_str = "SETUP";   // Address phase, waiting for enable
            2'b11: phase_str = "ACCESS";  // Data phase, transaction active
            default: phase_str = "UNKNOWN"; // Invalid protocol state
        endcase
        $display("Time: %0t, Phase: %s, paddr: %h, psel: %b, penable: %b, pwrite: %b, prdata: %h, pwdata: %h",
                 $time, phase_str, paddr, psel, penable, pwrite, prdata, pwdata);
    end

    // Set up virtual interface for UVM test environment
    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "", "apb_vif", apb_if_inst);
        uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_if_inst);

        // Enable waveform dumping for debugging (unless disabled)
        if (!$test$plusargs("DISABLE_WAVES")) begin
            $dumpfile("waves.vcd");
            $dumpvars(0, testbench);
        end

        // Start UVM test execution
        run_test();
    end

endmodule
