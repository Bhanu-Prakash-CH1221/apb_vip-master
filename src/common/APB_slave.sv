//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : APB_slave.sv
// Description  : APB Slave RTL DUT module
// Author       : CH Bhanu Prakash
// Notes        : Physical interface instantiation for slave side with memory modeling
//-----------------------------------------------------------------------------

`ifndef APB_SLAVE_RTL
`define APB_SLAVE_RTL
module APB_slave (
    input  logic        PCLK,          // System clock
    input  logic        PRESET_N,       // Active-low reset
    input  logic        PSEL,          // Peripheral select
    input  logic        PENABLE,        // Protocol enable
    input  logic        PWRITE,         // Write/read direction
    input  logic [31:0] PADDR,          // Address bus
    input  logic [31:0] PWDATA,         // Write data bus
    output logic [31:0] PRDATA_out,     // Read data output
    output logic [7:0]  write_count,    // Write transaction counter
    output logic [7:0]  read_count,     // Read transaction counter
    output logic        access_valid    // Access validity flag
);

    // Internal memory model (256 x 32-bit words)
    logic [31:0] mem [0:255];
    logic [7:0]  i;

    // Address counter for memory access tracking
    always_ff @(posedge PCLK or negedge PRESET_N) begin
        if (!PRESET_N)
            i <= 8'd0;
        else
            i <= i + 1'b1;
    end

    // Generate access valid signal based on protocol state
    always_comb begin
        access_valid = (PSEL && PENABLE) ? 1'b1 : 1'b0;
    end

    // Memory interface and transaction counting
    always_ff @(posedge PCLK or negedge PRESET_N) begin
        if (!PRESET_N) begin
            // Reset counters and memory
            write_count <= 8'd0;
            read_count  <= 8'd0;
            PRDATA_out  <= 32'd0;
            for (i = 0; i < 8'd255; i++) begin
                mem[i] <= 32'd0;
            end
            mem[255] <= 32'd0;
        end else begin
            if (PSEL && PENABLE) begin
                if (PWRITE) begin
                    // Write operation: store data in memory
                    mem[PADDR[9:2]] <= PWDATA;
                    write_count <= write_count + 1;
                end else begin
                    // Read operation: output data from memory
                    PRDATA_out <= mem[PADDR[9:2]];
                    read_count  <= read_count + 1;
                end
            end
        end
    end

endmodule
`endif
