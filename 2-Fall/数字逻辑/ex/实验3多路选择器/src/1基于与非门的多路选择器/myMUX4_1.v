`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 02:24:32
// Design Name: 
// Module Name: myMUX4_1
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


module myMUX4_1(
    input s0,
    input s1,
    input x0,
    input x1,
    input x2,
    input x3,
    output y
    );
    MUX4_1BD test(.a(s0),.a_1(s1),.c(x0),.c_1(x1),.c_2(x2),.c_3(x3),.y(y));
endmodule
