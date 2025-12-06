// medical_top_tb.v
// Full integration testbench for:
// ML Layer + Power FSM + Clock Manager (medical device power system)

`timescale 1ns/1ps

module medical_top_tb;

    reg clk;
    reg rst_n;

    // ML inputs
    reg signed [7:0] x1, x2;

    // System output
    wire [1:0] mode_out;

    // Instantiate the TOP module
    medical_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .x1(x1),
        .x2(x2),
        .mode_out(mode_out)
    );

    // Generate main system clock (10ns period = 100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Apply inputs
    initial begin
        $dumpfile("medical_top.vcd");
        $dumpvars(0, medical_top_tb);

        // Reset sequence
        rst_n = 0;
        x1 = 0;
        x2 = 0;
        #30;
        rst_n = 1;
        #20;

        // ----------------------------
        // Test Scenario:
        // Different ML workloads
        // ----------------------------

        // IDLE workload → low ML outputs expected
        x1 = 8'd10;  x2 = 8'd20;   // small values
        #200;

        // LOW workload
        x1 = 8'd30;  x2 = 8'd40;
        #300;

        // MED workload
        x1 = 8'd60;  x2 = 8'd80;
        #300;

        // HIGH workload
        x1 = 8'd100; x2 = 8'd120;
        #300;

        // Noise with small variations
        x1 = 8'd50; x2 = 8'd70;
        #200;

        // Extreme low workload again → return to IDLE
        x1 = 8'd5; x2 = 8'd10;
        #400;

        $display("Simulation complete.");
        $finish;
    end

endmodule
