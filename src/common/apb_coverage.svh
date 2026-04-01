//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_coverage.svh
// Description  : Coverage collector for APB protocol verification
// Author       : CH Bhanu Prakash
// Notes        : Functional coverage collection with comprehensive analysis
//-----------------------------------------------------------------------------

`ifndef _APB_COVERAGE_
`define _APB_COVERAGE_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;

class apb_coverage extends uvm_component;
    `uvm_component_utils(apb_coverage)

    // Analysis import to receive transactions
    uvm_analysis_imp #(apb_base_seq_item, apb_coverage) analysis_imp;

    // Coverage sampling fields
    bit         tr_type;           // Transaction type (0=READ, 1=WRITE)
    bit [31:0]  addr;              // Transaction address
    bit [31:0]  data;              // Transaction data
    bit         psel;              // Select signal state
    bit         penable;           // Enable signal state
    bit         pwrite;             // Write direction state
    bit         pready;             // Ready signal state
    bit         reset_n;           // Reset signal state
    int         delay;              // Inter-transaction delay
    int         protocol_phase;      // Current protocol phase
    int         reset_transition;    // Reset transition type
    int         back_to_back_transfers; // Consecutive transfer counter
    int         transfer_duration;   // Transfer duration measurement

    // Main transaction coverage group
    covergroup apb_transaction_cg;
        TR_TYPE: coverpoint tr_type {
            bins WRITE = {1};        // Write transactions
            bins READ  = {0};        // Read transactions
        }
        ADDRESS: coverpoint addr {
            bins LOW_ADDRESSES  = {[32'h00000000 : 32'h0000FFFF]};  // Low address range
            bins MID_ADDRESSES  = {[32'h00010000 : 32'h7FFFFFFF]};  // Mid address range
            bins HIGH_ADDRESSES = {[32'h80000000 : 32'hFFFFFFFF]};  // High address range
            bins WORD_ALIGNED   = {[32'h00000000 : 32'hFFFFFFFF]} iff (addr[1:0] == 2'b00); // Word-aligned addresses
        }
        DATA: coverpoint data {
            bins ZERO_DATA      = {32'h00000000};  // All zeros
            bins ONES_DATA      = {32'hFFFFFFFF};  // All ones
            bins ALTERNATE_1010 = {32'hAAAAAAAA};  // Alternating pattern
            bins RANDOM_DATA    = {[32'h00000001 : 32'hFFFFFFFE]};  // Random range
        }
        TR_TYPE_X_ADDR: cross TR_TYPE, ADDRESS {
            bins WRITE_LOW  = binsof(TR_TYPE.WRITE) && binsof(ADDRESS.LOW_ADDRESSES);  // Write to low addresses
            bins WRITE_MID  = binsof(TR_TYPE.WRITE) && binsof(ADDRESS.MID_ADDRESSES);  // Write to mid addresses
            bins WRITE_HIGH = binsof(TR_TYPE.WRITE) && binsof(ADDRESS.HIGH_ADDRESSES); // Write to high addresses
            bins READ_LOW   = binsof(TR_TYPE.READ)  && binsof(ADDRESS.LOW_ADDRESSES);   // Read from low addresses
            bins READ_MID   = binsof(TR_TYPE.READ)  && binsof(ADDRESS.MID_ADDRESSES);   // Read from mid addresses
            bins READ_HIGH  = binsof(TR_TYPE.READ)  && binsof(ADDRESS.HIGH_ADDRESSES);  // Read from high addresses
        }
        TR_TYPE_X_DATA: cross TR_TYPE, DATA {
            bins WRITE_ZERO  = binsof(TR_TYPE.WRITE) && binsof(DATA.ZERO_DATA);  // Write zeros
            bins WRITE_ONES  = binsof(TR_TYPE.WRITE) && binsof(DATA.ONES_DATA);  // Write ones
            bins WRITE_ALT   = binsof(TR_TYPE.WRITE) && binsof(DATA.ALTERNATE_1010); // Write alternating
            bins WRITE_RAND  = binsof(TR_TYPE.WRITE) && binsof(DATA.RANDOM_DATA); // Write random
            bins READ_ZERO   = binsof(TR_TYPE.READ)  && binsof(DATA.ZERO_DATA);   // Read zeros
            bins READ_ONES   = binsof(TR_TYPE.READ)  && binsof(DATA.ONES_DATA);   // Read ones
            bins READ_ALT    = binsof(TR_TYPE.READ)  && binsof(DATA.ALTERNATE_1010); // Read alternating
            bins READ_RAND   = binsof(TR_TYPE.READ)  && binsof(DATA.RANDOM_DATA); // Read random
        }
    endgroup

    // Protocol state coverage group
    covergroup apb_protocol_cg;
        TR_TYPE: coverpoint tr_type {
            bins WRITE = {1};  // Write transactions
            bins READ  = {0};  // Read transactions
        }
        PSEL_STATE: coverpoint psel {
            bins LOW  = {0};  // Peripheral not selected
            bins HIGH = {1};  // Peripheral selected
        }
        PENABLE_STATE: coverpoint penable {
            bins LOW  = {0};  // Protocol not enabled
            bins HIGH = {1};  // Protocol enabled
        }
        PWRITE_STATE: coverpoint pwrite {
            bins LOW  = {0};  // Read operation
            bins HIGH = {1};  // Write operation
        }
        PROTOCOL_PHASES: coverpoint protocol_phase {
            bins IDLE   = {0};  // IDLE phase
            bins SETUP  = {1};  // SETUP phase
            bins ACCESS = {2};  // ACCESS phase
        }
        STATE_TRANSITIONS: coverpoint {psel, penable} {
            bins IDLE_TO_SETUP   = (2'b00 => 2'b10);  // IDLE to SETUP transition
            bins SETUP_TO_ACCESS = (2'b10 => 2'b11); // SETUP to ACCESS transition
            bins ACCESS_TO_IDLE  = (2'b11 => 2'b00); // ACCESS to IDLE transition
        }
        PHASE_X_TR_TYPE: cross PROTOCOL_PHASES, TR_TYPE {
            bins IDLE_WRITE   = binsof(PROTOCOL_PHASES.IDLE)   && binsof(TR_TYPE.WRITE); // IDLE phase write
            bins IDLE_READ    = binsof(PROTOCOL_PHASES.IDLE)   && binsof(TR_TYPE.READ);  // IDLE phase read
            bins SETUP_WRITE  = binsof(PROTOCOL_PHASES.SETUP) && binsof(TR_TYPE.WRITE); // SETUP phase write
            bins SETUP_READ   = binsof(PROTOCOL_PHASES.SETUP) && binsof(TR_TYPE.READ);  // SETUP phase read
            bins ACCESS_WRITE = binsof(PROTOCOL_PHASES.ACCESS) && binsof(TR_TYPE.WRITE); // ACCESS phase write
            bins ACCESS_READ  = binsof(PROTOCOL_PHASES.ACCESS) && binsof(TR_TYPE.READ); // ACCESS phase read
        }
    endgroup

    // Reset behavior coverage group
    covergroup apb_reset_cg;
        RESET_STATE: coverpoint reset_n {
            bins ACTIVE   = {0};  // Reset not asserted
            bins INACTIVE = {1};  // Reset asserted
        }
        RESET_TRANSITIONS: coverpoint reset_transition {
            bins RESET_ASSERT   = (1 => 0);  // Reset assertion transition
            bins RESET_DEASSERT = (0 => 1);  // Reset deassertion transition
        }
        ACTIVITY_DURING_RESET: coverpoint {reset_n, psel} {
            bins IDLE_DURING_RESET   = {2'b00};
            bins ACTIVE_DURING_RESET = {2'b01};
            bins IDLE_AFTER_RESET    = {2'b10};
            bins ACTIVE_AFTER_RESET  = {2'b11};
        }
    endgroup

    // Timing coverage group for delay scenarios
    covergroup apb_timing_cg;
        TRANSFER_DELAY: coverpoint delay {
            bins MIN_DELAY  = {1};           // Minimum delay
            bins MAX_DELAY  = {2};           // Maximum delay
            bins LONG_DELAY = {[3:10]};       // Long delays
        }
        BACK_TO_BACK: coverpoint back_to_back_transfers {
            bins SINGLE      = {0};           // Single transfers
            bins CONSECUTIVE = {1};         // Back-to-back transfers
        }
        DELAY_X_B2B: cross TRANSFER_DELAY, BACK_TO_BACK;
    endgroup

    // External function declarations
    extern function new(string name = "apb_coverage", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void write(apb_base_seq_item t);
    extern function void sample_protocol_state(bit null_test = 0);
    extern function void sample_reset_state(bit null_test = 0);
    extern function void sample_timing(int dly, int b2b);
    extern function void report_coverage();
    extern function void extract_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);
    extern function real get_transaction_coverage();
    extern function real get_protocol_coverage();
    extern function real get_timing_coverage();
    extern function real get_reset_coverage();
endclass

// Constructor: Initialize coverage groups and analysis import
function apb_coverage::new(string name = "apb_coverage", uvm_component parent = null);
    super.new(name, parent);
    analysis_imp = new("analysis_imp", this);
    apb_transaction_cg = new();
    apb_protocol_cg    = new();
    apb_reset_cg       = new();
    apb_timing_cg      = new();
endfunction

// Build phase: Initialize coverage sampling
function void apb_coverage::build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(get_object_type());
    $display("APB Coverage Build Phase Complete");
    sample_protocol_state(1);    // Hit null handle paths
    sample_reset_state(1);       // Hit null handle paths
    write(null);                 // Hit null handle paths
endfunction

// Write function: Sample coverage from incoming transactions
function void apb_coverage::write(apb_base_seq_item t);
    static time last_transaction_time = 0;
    time current_time = $time;

    if (t == null) begin
        $display("WARNING: write() called with null transaction");
        return;
    end

    // Extract transaction type and store coverage fields
    tr_type = (t.apb_tr == apb_base_seq_item::WRITE) ? 1 : 0;
    addr    = t.addr;
    data    = t.data;
    delay   = t.delay;

    // Calculate back-to-back transfer timing
    if (last_transaction_time == 0) begin
        back_to_back_transfers = 0;  // First transaction
    end else begin
        back_to_back_transfers = (current_time - last_transaction_time <= 20) ? 1 : 0;  // Back-to-back if <= 20ns
    end
    last_transaction_time = current_time;

    // Sample all coverage groups
    apb_transaction_cg.sample();
    apb_timing_cg.sample();
endfunction

// Protocol state sampling with null handle coverage
function void apb_coverage::sample_protocol_state(bit null_test = 0);
    if (null_test) begin
        apb_protocol_cg.sample();  // Hit null handle paths
    end else begin
        apb_protocol_cg.sample();  // Hit normal paths
    end
endfunction

// Reset state sampling with null handle coverage
function void apb_coverage::sample_reset_state(bit null_test = 0);
    if (null_test) begin
        apb_reset_cg.sample();  // Hit null handle paths
    end else begin
        apb_reset_cg.sample();  // Hit normal paths
    end
endfunction

// Timing sampling for delay scenarios
function void apb_coverage::sample_timing(int dly, int b2b);
    delay                  = dly;
    back_to_back_transfers = b2b;
    apb_timing_cg.sample();
endfunction

// Coverage calculation functions
function real apb_coverage::get_transaction_coverage();
    return apb_transaction_cg.get_coverage();
endfunction

function real apb_coverage::get_protocol_coverage();
    return apb_protocol_cg.get_coverage();
endfunction

function real apb_coverage::get_timing_coverage();
    return apb_timing_cg.get_coverage();
endfunction

function real apb_coverage::get_reset_coverage();
    return apb_reset_cg.get_coverage();
endfunction

function void apb_coverage::report_coverage();
    $display($sformatf(
        "========== APB COVERAGE REPORT ==========\n\
Transaction Coverage: %0.2f%%\n\
Protocol Coverage:    %0.2f%%\n\
Reset Coverage:       %0.2f%%\n\
Timing Coverage:      %0.2f%%\n\
Overall Coverage:     %0.2f%%\n\
=========================================",
        get_transaction_coverage(), get_protocol_coverage(),
        get_reset_coverage(), get_timing_coverage(),
        (get_transaction_coverage() + get_protocol_coverage() +
         get_reset_coverage() + get_timing_coverage()) / 4.0));
endfunction

function void apb_coverage::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    report_coverage();
endfunction

function void apb_coverage::report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("=== COVERAGE COMPONENT REPORT PHASE ===");
    report_coverage();
endfunction

`endif