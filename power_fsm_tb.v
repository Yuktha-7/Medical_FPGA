`timescale 1ns/1ps
module power_fsm_tb;

    reg clk;
    reg rst_n;
    reg [1:0] ml_class_i;

    wire [1:0] mode_o;
    wire [1:0] clk_sel_o;
    wire enable_ml_o;
    wire [1:0] vmode_o;

    // Instantiate with small timers for simulation quickness
    power_fsm #(
        .HYST_COUNT(3),     // require 3 stable samples
        .DWELL_CYCLES(20)   // remain min 20 cycles in a mode
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ml_class_i(ml_class_i),
        .mode_o(mode_o),
        .clk_sel_o(clk_sel_o),
        .enable_ml_o(enable_ml_o),
        .vmode_o(vmode_o)
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz style (10ns period)

    initial begin
        $dumpfile("power_fsm.vcd");
        $dumpvars(0, power_fsm_tb);

        // reset
        rst_n = 0;
        ml_class_i = 2'd0;
        #30;
        rst_n = 1;
        #20;

        // Scenario sequence:
        // start idle for some time
        ml_class_i = 2'd0; #100;

        // noisy input: flicker between 0 and 1 -> should remain IDLE due to hysteresis/dwell
        ml_class_i = 2'd1; #10;
        ml_class_i = 2'd0; #10;
        ml_class_i = 2'd1; #10;
        ml_class_i = 2'd1; #10;
        ml_class_i = 2'd1; #100; // sustained -> transition to LOW

        // climb to MED (simulate brief noise then stable MED)
        ml_class_i = 2'd2; #10;
        ml_class_i = 2'd1; #10;
        ml_class_i = 2'd2; #10;
        ml_class_i = 2'd2; #100; // sustain -> transition to MED

        // immediate jump to HIGH, ensure hysteresis still required
        ml_class_i = 2'd3; #10;
        ml_class_i = 2'd3; #10;
        ml_class_i = 2'd3; #100; // sustain -> transition to HIGH

        // noise back to LOW but short -> should not drop due to dwell timer
        ml_class_i = 2'd1; #30; // short
        ml_class_i = 2'd3; #100; // remain HIGH

        // allow time then force into IDLE
        ml_class_i = 2'd0; #200;

        $display("Test complete");
        $finish;
    end

    // display state changes
    reg [1:0] prev_mode;
    initial prev_mode = 2'bxx;
    always @(posedge clk) begin
        if (mode_o !== prev_mode) begin
            $display("[%0t] MODE_CHANGE: mode=%0d clk_sel=%0d enable_ml=%b vmode=%0d ml_in=%0d",
                     $time, mode_o, clk_sel_o, enable_ml_o, vmode_o, ml_class_i);
            prev_mode <= mode_o;
        end
    end

endmodule
