`timescale 1ns/1ps
module clock_manager_tb;

    reg clk;
    reg rst_n;
    reg [1:0] clk_sel_i;

    wire clk_out;

    clock_manager dut (
        .clk(clk),
        .rst_n(rst_n),
        .clk_sel_i(clk_sel_i),
        .clk_out(clk_out)
    );

    // main clock (100MHz → 10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("clock_manager.vcd");
        $dumpvars(0, clock_manager_tb);

        rst_n = 0;
        clk_sel_i = 2'b11; // start full speed
        #50;
        rst_n = 1;

        // Go to half speed
        #200; clk_sel_i = 2'b10;

        // Go to /4
        #200; clk_sel_i = 2'b01;

        // Go to /8
        #200; clk_sel_i = 2'b00;

        // Jump to full
        #200; clk_sel_i = 2'b11;

        #300;
        $finish;
    end

endmodule
