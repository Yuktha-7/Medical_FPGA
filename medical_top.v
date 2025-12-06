// medical_top.v
// Connect ML Layer → FSM → Clock Manager

module medical_top (
    input wire clk,
    input wire rst_n,
    input wire signed [7:0] x1,
    input wire signed [7:0] x2,
    output wire [1:0] mode_out
);

    //---------------------------------------------
    // 1. ML Layer (Your existing 4-neuron layer)
    //---------------------------------------------

    wire signed [7:0] out0, out1, out2, out3;

    ml_layer_mem u_ml (
        .clk       (scaled_clk),   // <-- IMPORTANT!!
        .rst_n     (rst_n),
        .x1        (x1),
        .x2        (x2),
        .out0      (out0),
        .out1      (out1),
        .out2      (out2),
        .out3      (out3)
    );

    //------------------------------------------------
    // 2. ML class selection (priority encoder)
    //------------------------------------------------

    reg [1:0] ml_class_i;

    always @(*) begin
        // Pick the neuron with the highest activation
        if (out3 > out2 && out3 > out1 && out3 > out0)
            ml_class_i = 2'd3;
        else if (out2 > out1 && out2 > out0)
            ml_class_i = 2'd2;
        else if (out1 > out0)
            ml_class_i = 2'd1;
        else
            ml_class_i = 2'd0;
    end

    //------------------------------------------------
    // 3. Power FSM
    //------------------------------------------------

    wire [1:0] clk_sel_o;

    power_fsm u_fsm (
        .clk        (clk),
        .rst_n      (rst_n),
        .ml_class_i (ml_class_i),
        .mode_o     (mode_out),
        .clk_sel_o  (clk_sel_o),
        .enable_ml_o(),
        .vmode_o()
    );

    //------------------------------------------------
    // 4. Clock Manager
    //------------------------------------------------

    wire scaled_clk;

    clock_manager u_clkman (
        .clk        (clk),
        .rst_n      (rst_n),
        .clk_sel_i  (clk_sel_o),
        .clk_out    (scaled_clk)
    );

endmodule
