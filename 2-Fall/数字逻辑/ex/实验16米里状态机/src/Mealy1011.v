`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 20:52:23
// Design Name: 
// Module Name: Mealy1101
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


module Mealy1011
//#(parameter DW = 8)(clk,rst,set,din,res);
#(parameter DW = 8,sign=1)(clk,rst,set,din,res,flag);
    input clk,rst,set;
    input [DW-1:0]din;
    output reg flag=1'b0;
    output reg res;
    
    parameter [1:0]s0=2'b00,s1=2'b01,s2=2'b10,s3=2'b11;
    reg [1:0]next,curr;    
    wire myclk;
    
    if(sign) begin // 上板
        integer f=32'd5000_0000; // halfT=0.5s
        fdivider fdivider01(.clk(clk),.f(f),.myclk(myclk));
    end else begin // 仿真
        assign myclk = clk;
    end
    
    // 并转串自模块调用
    // wire x;
    // par2ser#(DW) par2ser01(.clk(myclk),.rst(rst),.set(set),.din(din),.x(x));
    
    // 内置左移模块（输入数据，得到右移结果，异步重置）
    reg x;
    reg [DW-1:0]data={DW{1'b0}};
    always@(posedge myclk,posedge rst,posedge set) begin
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
    
    // 次现态转换 
    always@(posedge myclk,posedge rst) begin
        if(rst) begin
            curr <= s0;
            next <= s0;
        end
        else begin
            case(curr)
                s0: next = x ? s1 : s0;
                s1: next = ~x ? s2 : s1;
                s2: next = x ? s3 : s0;
                s3: next = x ? s1 : s2;
            endcase
            curr <= next;
        end
    end
    
    // 输出结果
    always@(posedge myclk, posedge rst) begin
        if(rst) begin
            res = 0;
            flag = 0;
        end
        else begin
            if(curr==s3 && x==1) begin
                res = 1;
            end
            else res = 0;
            if(res) flag = 1'b1;
        end
    end
    
//    always@(res) begin
//        if(res) flag = 1'b1;
//        else flag = flag;
//    end
endmodule
