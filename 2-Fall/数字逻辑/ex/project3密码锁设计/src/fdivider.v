`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 18:31:59
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
    
    reg inlineclk;
    reg [31:0]cnt=1'b0;
    always@(posedge clk) begin
        if(cnt == f) begin
            inlineclk = ~inlineclk;
            cnt = 1'b0; 
        end
        else cnt = cnt + 1'b1;
    end
    
    assign myclk = inlineclk;
endmodule
