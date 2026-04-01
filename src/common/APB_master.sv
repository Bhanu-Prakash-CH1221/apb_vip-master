//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : APB_master.sv
// Description  : APB Master RTL DUT module
// Author       : CH Bhanu Prakash
// Notes        : Physical interface instantiation for master side with protocol checking
//-----------------------------------------------------------------------------

`ifndef APB_MASTER_RTL
`define APB_MASTER_RTL
module APB_master (
    input  logic        PCLK,          // System clock
    input  logic        PRESET_N,       // Active-low reset
    input  logic        PSEL,          // Peripheral select
    input  logic        PENABLE,        // Protocol enable
    input  logic        PWRITE,         // Write/read direction
    input  logic        PREADY,         // Transfer ready
    input  logic [31:0] PADDR,          // Address bus
    input  logic [31:0] PWDATA,         // Write data bus
    input  logic [31:0] PRDATA,         // Read data bus
    output logic [1:0]  apb_phase,     // Current APB phase
    output logic [7:0]  write_count,    // Write transaction counter
    output logic [7:0]  read_count,     // Read transaction counter
    output logic        protocol_error  // Protocol error flag
);

    // APB phase decoder for protocol monitoring
    always_comb begin
        if (!PRESET_N) begin
            apb_phase = 2'b00;  // IDLE state
        end else begin
            casez ({PSEL, PENABLE})
                2'b11: apb_phase = 2'b10;  // SETUP phase
                2'b10: apb_phase = 2'b01;  // ACCESS phase
                default: apb_phase = 2'b00;  // IDLE state
            endcase
        end
    end

    // Transaction counters and protocol checking
    always_ff @(posedge PCLK or negedge PRESET_N) begin
        if (!PRESET_N) begin
            // Reset all counters and error flag
            write_count    <= 8'd0;
            read_count     <= 8'd0;
            protocol_error <= 1'b0;
        end else begin
            // Count write transactions
            if (PSEL && PENABLE && PREADY && PWRITE)
                write_count <= write_count + 1;
            // Count read transactions
            if (PSEL && PENABLE && PREADY && !PWRITE)
                read_count  <= read_count + 1;
            // Detect protocol error: PENABLE without PSEL
            if (!PSEL && PENABLE)
                protocol_error <= 1'b1;
            else
                protocol_error <= 1'b0;
        end
    end

endmodule
`endif
