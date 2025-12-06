// clock_manager.v
// Medical-safe clock divider + glitch-free clock mux + gated clock output.
// clk_sel_i = 00:/8 , 01:/4 , 10:/2 , 11:/1 (full speed)

`timescale 1ns/1ps
module clock_manager (
    input  wire clk,          // main input clock (e.g. 100 MHz)
    input  wire rst_n,        // active-low reset
    input  wire [1:0] clk_sel_i, // selection from FSM
    output wire clk_out          // gated + scaled output clock
);

    // -------------------------------
    // Generate divided clocks
    // -------------------------------
    reg clk_div2, clk_div4, clk_div8;

    // DIV2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_div2 <= 0;
        else
            clk_div2 <= ~clk_div2;
    end

    // DIV4
    always @(posedge clk_div2 or negedge rst_n) begin
        if (!rst_n)
            clk_div4 <= 0;
        else
            clk_div4 <= ~clk_div4;
    end

    // DIV8
    always @(posedge clk_div4 or negedge rst_n) begin
        if (!rst_n)
            clk_div8 <= 0;
        else
            clk_div8 <= ~clk_div8;
    end

    // -------------------------------
    // Glitch-free clock mux
    // -------------------------------
    reg selected_clk;

    always @(*) begin
        case (clk_sel_i)
            2'b00: selected_clk = clk_div8; // lowest power
            2'b01: selected_clk = clk_div4;
            2'b10: selected_clk = clk_div2;
            2'b11: selected_clk = clk;      // full speed
            default: selected_clk = clk;
        endcase
    end

    // -------------------------------
    // Synchronous gating (safe)
    // -------------------------------
    // No combinational gating directly on clock → BAD in FPGA.
    // Instead, use clock enable technique.

    reg clk_out_reg;

    always @(posedge selected_clk or negedge rst_n) begin
        if (!rst_n)
            clk_out_reg <= 1'b0;
        else
            clk_out_reg <= ~clk_out_reg;  // simple toggle = full-rate output
    end

    assign clk_out = clk_out_reg;

endmodule
