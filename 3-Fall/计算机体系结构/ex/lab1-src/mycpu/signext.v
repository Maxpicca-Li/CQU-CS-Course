`timescale 1ns / 1ps
// sign extend
module signext (
    input wire [15:0]a, // input wire [15:0]a
    output wire [31:0]y // output wire [31:0]y
);
    assign y = {{16{a[15]}},a};
endmodule