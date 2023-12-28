`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 00:30:48
// Design Name: 
// Module Name: MUX4_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MUX4_1
#(parameter WIDTH=3)(
    input [(WIDTH-1):0]x0,
    input [(WIDTH-1):0]x1,
    input [(WIDTH-1):0]x2,
    input [(WIDTH-1):0]x3,
    input s0,
    input s1,
    output [(WIDTH-1):0]y
    );
    myMUX4_1 test(
        .s(s0),
        .s_1(s1),
        .x1(x0), // s_1 = 0  s0 = 0
        .x1_1(x2), // s_1 = 1 s0 = 0 
        .x2(x1), // s_1 = 0 s0 = 1
        .x2_1(x3), // s_1 = 1 s0 = 1
        .y(y));
endmodule
