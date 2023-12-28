`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/02 01:02:45
// Design Name: 
// Module Name: debkey
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


module debkey(clk,rst,button,btn);
    input clk,rst;
    input [3:0]button;
    output [3:0]btn;
    
    wire myclk;
    integer f=32'd50_0000; // halfT = 5ms = 5e-3
    fdivider fdivider01(.clk(clk),.f(f),.myclk(myclk));
    
//    reg [4:0]last; // 也能成功防抖
//    always@(posedge myclk) last = button;
//    assign btn = (last==button)?last:5'b0;
        
    reg [4:0]key_rr,key_r;
    always@(posedge myclk,posedge rst) begin
        if(rst) begin
            key_r <= 5'b0;
            key_rr <= 5'b0;
        end
        else begin
            key_r <= button;
            key_rr <= key_r;     
        end
    end
    assign btn = key_r & key_rr; // 总共延迟10+10 = 20ms
    
endmodule
