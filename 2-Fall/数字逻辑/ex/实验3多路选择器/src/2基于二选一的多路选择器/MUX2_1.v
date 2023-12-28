`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 01:59:48
// Design Name: 
// Module Name: MUX2_1
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


module MUX2_1
#(parameter WIDTH=1)(
    input [(WIDTH-1):0]x1,
    input [(WIDTH-1):0]x2,
    input s,
    output [(WIDTH-1):0]y
    );
    assign y=(s==1)?x2:x1;
endmodule
