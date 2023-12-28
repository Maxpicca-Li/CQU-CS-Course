`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/19 01:02:43
// Design Name: 
// Module Name: divide
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



module divide(x,y,f,re);
    input [31:0]x;
    input [31:0]y;
    output reg [31:0]f;
    output reg [31:0]re; 
    integer i;
    always@(*)begin
        re = 32'b0;
        f = 32'b0;
        for(i=31;i>=0;i=i-1) begin
            re = re << 1;
            re = re + x[i];
            f = f << 1;
            if(re >= y) begin
                re = re - y;
                f = f + 1'b1;
            end
        end
    end 
endmodule
