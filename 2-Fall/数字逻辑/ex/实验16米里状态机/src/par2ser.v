`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/27 14:38:37
// Design Name: 
// Module Name: par2ser
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


module par2ser
#(parameter DW = 8)(clk,rst,set,din,x);
    input clk,rst,set;
    input [DW-1:0]din;
    output reg x;
    
    reg [DW-1:0]data={DW{1'b0}};
    // 输入数据，得到右移结果，貌似需要 异步重置
    always@(posedge clk,posedge rst,posedge set) begin
        if(rst) begin
            data = {DW{1'b0}};
            x = 1'b0;
        end
        else if(set) begin
            data = din;
            x = 1'b0;
        end
        else begin
            x = data[DW-1];
            data = data << 1;
        end 
    end
endmodule
