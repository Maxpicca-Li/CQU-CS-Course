`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/13 15:15:43
// Design Name: 
// Module Name: MUX4_1algori\
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


module MUX4_1algori
#(parameter WIDTH=3)(a,x0,x1,x2,x3,y);  
    input [1:0]a; // —°‘Ò÷∏¡Ó  
    input [(WIDTH-1):0]x0,x1,x2,x3;  
    output [(WIDTH-1):0]y;  
    assign y=a[1]?(a[0]?x3:x2):(a[0]?x1:x0);  
endmodule
