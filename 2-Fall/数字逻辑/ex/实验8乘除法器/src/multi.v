`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/16 21:52:48
// Design Name: 
// Module Name: multi
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

//module multi
//#(parameter WIDTH=32)(x,y,f);
module multi(x,y,f);
    input [31:0]x;
    input [31:0]y;
    output reg [63:0]f;
    reg [63:0]tx;
    integer i;
    always@(*)begin
        f = 64'b0;
        tx = x;
        for(i=0;i<=31;i=i+1) begin
            if(y[i] == 1'b1) f = f + tx;
            tx = tx << 1; 
        end
    end
endmodule
