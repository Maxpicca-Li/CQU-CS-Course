`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/24 01:45:25
// Design Name: 
// Module Name: fdivider
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


module fdivider(clk,f,myclk);
    input clk;
    input [31:0]f;
    output myclk;
    
    reg[31:0] clk_cnt=1'b0;
    reg inlineclk = 0;
    always@(posedge clk) begin
        if(clk_cnt == f[31:0]) begin 
            clk_cnt<=1'b0;
            inlineclk <=~inlineclk;
        end
        else clk_cnt<=clk_cnt+1'b1;
    end
    assign myclk = inlineclk;
endmodule