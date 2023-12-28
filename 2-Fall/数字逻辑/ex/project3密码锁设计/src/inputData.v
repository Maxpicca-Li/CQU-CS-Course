`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/02 00:05:35
// Design Name: 
// Module Name: inputData
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


module inputData #(parameter DW = 8)
(rst,btn,btnclk,din,data);
//(rst,btn,btnclk,din);
    input rst;
    input [3:0]btn;
    output btnclk; // 按键响应模拟时钟
    output reg [1:0]din;
    output [15:0]data;
    
    always@(posedge btn[0],posedge btn[1],posedge btn[2],posedge btn[3],posedge rst) begin
        if(rst) begin
            din <= 2'b00;
        end
        else begin 
            if(btn[0]) din <= 2'b00;
            else if(btn[1]) din <= 2'b01;
            else if(btn[2]) din <= 2'b10;
            else begin din <= 2'b11; end
        end
    end
    
    assign btnclk = btn[0] | btn[1] | btn[2] | btn[3];
    
    reg [3:0]cnt = 3'b0;
    reg [15:0]temp;
    // 这里需要捕获下降沿哦
    always@(negedge btnclk,posedge rst) begin
        if(rst) begin
            cnt = 3'b000;
            temp = {16{1'b0}};
        end
        else begin
            if(cnt == 3'd4) begin
                cnt = 3'b000;
                temp = {16{1'b0}};
            end
            cnt = cnt + 1'b1;
            temp = (temp << 4) + {2'b00,din[1:0]}; // 这里不应该用非阻塞赋值，emmm
        end
    end
    assign data = temp;
    
endmodule