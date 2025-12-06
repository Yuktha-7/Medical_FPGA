// power_fsm.v
// Power controller FSM with hysteresis + dwell timer (Option D - medical-grade)
// - Inputs:
//    clk         : system clock
//    rst_n       : active-low synchronous reset
//    ml_class_i  : 2-bit class from ML predictor (0=IDLE,1=LOW,2=MED,3=HIGH)
// - Outputs:
//    mode_o      : 2-bit current power mode (0..3 same encoding)
//    clk_sel_o   : 2-bit clock select (0:/8, 1:/4, 2:/2, 3:/1)
//    enable_ml_o : enable signal for ML accelerator (1 when mode >= MED)
//    vmode_o     : 2-bit simulated voltage mode (same as mode_o)

`timescale 1ns/1ps
module power_fsm #(
    parameter integer HYST_COUNT       = 4,        // consecutive samples required to accept a new ml_class
    parameter integer DWELL_CYCLES     = 50        // minimum cycles to remain in a mode before change
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  ml_class_i,
    output reg  [1:0]  mode_o,
    output reg  [1:0]  clk_sel_o,
    output reg         enable_ml_o,
    output reg  [1:0]  vmode_o
);

    // Local state encoding (same as mode)
    localparam IDLE = 2'd0;
    localparam LOW  = 2'd1;
    localparam MED  = 2'd2;
    localparam HIGH = 2'd3;

    // Sampled ml_class and hysteresis counter
    reg [1:0] sampled_ml;            // last sampled ml_class
    integer   hyst_count;

    // Dwell timer to enforce minimum stay in a mode
    integer   dwell_counter;

    // Candidate mode derived from stable ml_class
    reg [1:0] candidate_mode;

    // update sampled_ml + hysteresis (synchronous)
    always @(posedge clk) begin
        if (!rst_n) begin
            sampled_ml   <= IDLE;
            hyst_count   <= 0;
            candidate_mode <= IDLE;
        end else begin
            if (ml_class_i == sampled_ml) begin
                if (hyst_count < HYST_COUNT)
                    hyst_count <= hyst_count + 1;
            end else begin
                sampled_ml <= ml_class_i;
                hyst_count <= 1;
            end

            // Accept candidate only when hyst_count reached threshold
            if (hyst_count >= HYST_COUNT)
                candidate_mode <= sampled_ml;
        end
    end

    // FSM transitions with dwell timer
    always @(posedge clk) begin
        if (!rst_n) begin
            mode_o      <= IDLE;
            clk_sel_o   <= IDLE; // match encoding: /8,/4,/2,/1
            enable_ml_o <= 1'b0;
            vmode_o     <= IDLE;
            dwell_counter <= 0;
        end else begin
            // increment dwell counter (saturates to a large number)
            if (dwell_counter < DWELL_CYCLES + 2)
                dwell_counter <= dwell_counter + 1;

            // Only allow mode change if candidate differs and dwell time satisfied
            if (candidate_mode != mode_o && dwell_counter >= DWELL_CYCLES) begin
                // change mode to candidate
                mode_o <= candidate_mode;
                dwell_counter <= 0; // reset dwell on mode change
            end

            // outputs mapping
            clk_sel_o <= mode_o;   // simple mapping: same encoding => clk divider selection
            vmode_o   <= mode_o;   // simulated voltage mode

            // enable ML only in MED/HIGH (configurable)
            if (mode_o >= MED)
                enable_ml_o <= 1'b1;
            else
                enable_ml_o <= 1'b0;
        end
    end

endmodule
