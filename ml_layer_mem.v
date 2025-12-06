// ml_layer_mem.v
// 4-neuron ML layer that loads weights from weights.hex using $readmemh

module ml_layer_mem(
    input  signed [7:0] x1,
    input  signed [7:0] x2,

    output signed [7:0] out0,
    output signed [7:0] out1,
    output signed [7:0] out2,
    output signed [7:0] out3,

    // optional: debug/export intermediate values
    output signed [15:0] mul1_0, mul2_0, sum_0,
    output signed [15:0] mul1_1, mul2_1, sum_1,
    output signed [15:0] mul1_2, mul2_2, sum_2,
    output signed [15:0] mul1_3, mul2_3, sum_3
);

    // -------------------------------------------
    // 1. Weight Memory (12 entries = 4 neurons × 3 params each)
    // W[0]  = w1_0
    // W[1]  = w2_0
    // W[2]  = bias_0
    // W[3]  = w1_1
    // W[4]  = w2_1
    // W[5]  = bias_1
    // etc...
    // -------------------------------------------

    reg signed [7:0] W [0:11];

    initial begin
        $display("Loading weights from weights.hex...");
        $readmemh("weights.hex", W);
    end

    // -------------------------------------------
    // 2. Map memory to neuron parameters
    // -------------------------------------------

    wire signed [7:0] w1_0 = W[0];
    wire signed [7:0] w2_0 = W[1];
    wire signed [7:0] bias_0 = W[2];

    wire signed [7:0] w1_1 = W[3];
    wire signed [7:0] w2_1 = W[4];
    wire signed [7:0] bias_1 = W[5];

    wire signed [7:0] w1_2 = W[6];
    wire signed [7:0] w2_2 = W[7];
    wire signed [7:0] bias_2 = W[8];

    wire signed [7:0] w1_3 = W[9];
    wire signed [7:0] w2_3 = W[10];
    wire signed [7:0] bias_3 = W[11];

    // -------------------------------------------
    // 3. Instantiate neurons
    // -------------------------------------------

    neuron n0 (
        .x1(x1), .x2(x2),
        .w1(w1_0), .w2(w2_0), .bias(bias_0),
        .out(out0),
        .mul1(mul1_0), .mul2(mul2_0), .sum(sum_0)
    );

    neuron n1 (
        .x1(x1), .x2(x2),
        .w1(w1_1), .w2(w2_1), .bias(bias_1),
        .out(out1),
        .mul1(mul1_1), .mul2(mul2_1), .sum(sum_1)
    );

    neuron n2 (
        .x1(x1), .x2(x2),
        .w1(w1_2), .w2(w2_2), .bias(bias_2),
        .out(out2),
        .mul1(mul1_2), .mul2(mul2_2), .sum(sum_2)
    );

    neuron n3 (
        .x1(x1), .x2(x2),
        .w1(w1_3), .w2(w2_3), .bias(bias_3),
        .out(out3),
        .mul1(mul1_3), .mul2(mul2_3), .sum(sum_3)
    );

endmodule
