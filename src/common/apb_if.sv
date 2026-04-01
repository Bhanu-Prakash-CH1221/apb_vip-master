//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_if.sv
// Description  : Main APB interface with assertions and protocol checking
// Author       : CH Bhanu Prakash
// Notes        : Complete APB protocol signal definition and assertions
//-----------------------------------------------------------------------------

`ifndef _APB_IF_
`define _APB_IF_

`include "apb_defines.svh"
interface apb_if(input bit PCLK, PRESET_N);

    // APB protocol signals (32-bit address and data bus)
    logic [`ADDR_WIDTH-1:0] PADDR;     // Address bus
    logic [`DATA_WIDTH-1:0] PWDATA;    // Write data bus
    logic [`DATA_WIDTH-1:0] PRDATA;    // Read data bus
    logic PSEL;                         // Select signal
    logic PENABLE;                       // Enable signal
    logic PWRITE;                        // Write/read direction
    logic PREADY;                        // Ready signal

    // Master clocking block - drives APB bus signals
    clocking master_cb @(posedge PCLK);
        output PADDR, PSEL, PENABLE, PWRITE, PWDATA;
        input  PRDATA, PREADY;
    endclocking: master_cb

    // Slave clocking block - receives APB bus signals
    clocking slave_cb @(posedge PCLK);
        input  PADDR, PSEL, PENABLE, PWRITE, PWDATA;
        output PRDATA, PREADY;
    endclocking: slave_cb

    // Modports for master and slave connections
    modport master( input  PRDATA, PREADY, PRESET_N,
                    output PADDR, PSEL, PENABLE, PWRITE, PWDATA );

    modport slave(  input  PADDR, PSEL, PENABLE, PWRITE, PWDATA, PRESET_N,
                    output PRDATA, PREADY );

    // APB protocol state definitions for assertions
    `define IDLE   (!PSEL & !PENABLE)    // No transaction active
    `define SETUP  ( PSEL & !PENABLE)    // Address phase
    `define ACCESS ( PSEL &  PENABLE)    // Data phase

    // Protocol phase sequences for assertion checking
    sequence idle_phase;
        (!PSEL & !PENABLE);
    endsequence

    sequence setup_phase;
        ( PSEL & !PENABLE);
    endsequence

    sequence access_phase;
        ( PSEL &  PENABLE);
    endsequence

    // APB protocol assertions for compliance checking
    property psel_valid;
        @(posedge PCLK) disable iff (PRESET_N == 1'b0)
            !$isunknown(PSEL);  // PSEL should never be unknown
    endproperty: psel_valid

    assert property(psel_valid);
    cover  property(psel_valid);

    // Assertion: Address must remain stable during SETUP to ACCESS transition
    property setup_to_stable_1;
        @(posedge PCLK) disable iff (!PRESET_N)
            setup_phase |=> $stable(PADDR);  // Address stable in next cycle
    endproperty

    assert property (setup_to_stable_1)
    else $display("setup_to_stable_1 Assertion failed");
    cover property (@(posedge PCLK) disable iff (!PRESET_N)
        setup_phase |=> $stable(PADDR));

    // Assertion: Write data must remain stable during SETUP to ACCESS transition
    property setup_to_stable_2;
        @(posedge PCLK) disable iff (!PRESET_N)
            setup_phase |=> $stable(PWDATA);  // Write data stable in next cycle
    endproperty

    assert property (setup_to_stable_2)
    else $display("setup_to_stable_2 Assertion failed");
    cover property (@(posedge PCLK) disable iff (!PRESET_N)
        setup_phase |=> $stable(PWDATA));

    // Assertion: Select signal must remain stable during SETUP to ACCESS transition
    property setup_to_stable_3;
        @(posedge PCLK) disable iff (!PRESET_N)
            setup_phase |=> $stable(PSEL);  // Select stable in next cycle
    endproperty

    assert property (setup_to_stable_3)
    else $display("setup_to_stable_3 Assertion failed");
    cover property (@(posedge PCLK) disable iff (!PRESET_N)
        setup_phase |=> $stable(PSEL));

    // Assertion: During write transfer, data must be stable and PENABLE must eventually fall
    property write_transfer;
        @(posedge PCLK) disable iff (!PRESET_N)
            (PSEL & PWRITE & PENABLE) |->
                ($stable(PWDATA) and ##[1:$] $fell(PENABLE));  // Data stable, enable falls
    endproperty

    assert property (write_transfer)
    else $display("write_transfer Assertion failed");
    cover property (@(posedge PCLK) disable iff (!PRESET_N)
        (PSEL & PWRITE & PENABLE) |->
            ($stable(PWDATA) and ##[1:$] $fell(PENABLE)));

    // Assertion: During read transfer, PRDATA must change and PCLK must rise
    property read_transfer;
        @(PCLK) disable iff (!PRESET_N)
            PSEL & !PWRITE & PENABLE & PREADY & $changed(PRDATA) |-> $rose(PCLK)
    endproperty

    assert property (read_transfer)
    else $display("read_transfer Assertion failed");
    cover property (@(PCLK) disable iff (!PRESET_N)
        PSEL & !PWRITE & PENABLE & PREADY & $changed(PRDATA) |-> $rose(PCLK));

endinterface

`endif
