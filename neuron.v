// 8-bit fixed point neuron with ReLU
module neuron(
    input  signed [7:0] x1,
    input  signed [7:0] x2,
    input  signed [7:0] w1,
    input  signed [7:0] w2,
    input  signed [7:0] bias,
    output signed [7:0] out, 
    output signed [15:0] mul1, mul2, sum
);
assign mul1 = x1 * w1;
assign mul2 = x2 * w2;
assign sum  = mul1 + mul2 + {bias, 8'd0};


assign out  = (sum > 0) ? sum[15:8] : 8'd0;

endmodule
