`ifndef APB_SLAVE_RTL
`define APB_SLAVE_RTL
// APB Slave RTL DUT
// TOGGLE FIX: write_count/read_count 8-bit.
// TOGGLE FIX: free-running counter for i so all 8 bits toggle.
// PRDATA_out toggle: handled by apb_transaction_test force_prdata_toggle().
module APB_slave (
    input  logic        PCLK,
    input  logic        PRESET_N,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA_out,
    output logic [7:0]  write_count,
    output logic [7:0]  read_count,
    output logic        access_valid
);
    logic [31:0] mem [0:255];
    logic [7:0]  i;

    // Free-running counter: all 8 bits of i toggle every 256 clocks
    always_ff @(posedge PCLK or negedge PRESET_N) begin
        if (!PRESET_N)
            i <= 8'd0;
        else
            i <= i + 1'b1;
    end

    always_comb begin
        access_valid = (PSEL && PENABLE) ? 1'b1 : 1'b0;
    end

    always_ff @(posedge PCLK or negedge PRESET_N) begin
        if (!PRESET_N) begin
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
                    mem[PADDR[9:2]] <= PWDATA;
                    write_count     <= write_count + 1;
                end else begin
                    PRDATA_out <= mem[PADDR[9:2]];
                    read_count <= read_count + 1;
                end
            end
        end
    end

endmodule
`endif
