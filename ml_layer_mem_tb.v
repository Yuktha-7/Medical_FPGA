`timescale 1ns/1ps

module ml_layer_mem_tb;

    reg signed [7:0] x1, x2;

    wire signed [7:0] out0, out1, out2, out3;

    wire signed [15:0] mul1_0, mul2_0, sum_0;
    wire signed [15:0] mul1_1, mul2_1, sum_1;
    wire signed [15:0] mul1_2, mul2_2, sum_2;
    wire signed [15:0] mul1_3, mul2_3, sum_3;

    // Instantiate the DUT (Device Under Test)
    ml_layer_mem dut (
        .x1(x1),
        .x2(x2),

        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3),

        .mul1_0(mul1_0), .mul2_0(mul2_0), .sum_0(sum_0),
        .mul1_1(mul1_1), .mul2_1(mul2_1), .sum_1(sum_1),
        .mul1_2(mul1_2), .mul2_2(mul2_2), .sum_2(sum_2),
        .mul1_3(mul1_3), .mul2_3(mul2_3), .sum_3(sum_3)
    );

    initial begin
        // VCD dump (waveform file)
        $dumpfile("ml_layer_mem.vcd");
        $dumpvars(0, ml_layer_mem_tb);

        // Wait a bit for $readmemh to complete
        #5;

        // ------------------------------------------------------
        // Stimulus sequence
        // ------------------------------------------------------

        x1 = 8'sd10; x2 = 8'sd20; #10;
        $display("T1: x1=%0d x2=%0d | out=%0d %0d %0d %0d",
            x1, x2, out0, out1, out2, out3);

        x1 = 8'sd30; x2 = 8'sd50; #10;
        $display("T2: x1=%0d x2=%0d | out=%0d %0d %0d %0d",
            x1, x2, out0, out1, out2, out3);

        x1 = 8'sd60; x2 = 8'sd120; #10;
        $display("T3: x1=%0d x2=%0d | out=%0d %0d %0d %0d",
            x1, x2, out0, out1, out2, out3);

        x1 = -8'sd40; x2 = 8'sd10; #10;
        $display("T4: x1=%0d x2=%0d | out=%0d %0d %0d %0d",
            x1, x2, out0, out1, out2, out3);

        $finish;
    end

endmodule
