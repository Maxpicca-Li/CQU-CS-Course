`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/25 12:10:40
// Design Name: 
// Module Name: FIFO_syn
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

module FIFO_syn
#(parameter AW=4,DW=8)
(clk,key,rst,wen,ren,din,wfull,rempty,res_wei,res_duan);
    parameter RD = 1 << AW;
	input clk,key,rst,wen,ren;
	input [DW-1:0]din;
	output [3:0]res_wei;
    output [6:0]res_duan;
    output wfull,rempty;
	
    // 内置信号
	reg [AW-1:0]waddr=1'b0,raddr=1'b0;
	reg [AW:0]cnt = 1'b0; // 若AW=4,则cnt共有17种状态，0（空）~16（满）
	reg [DW-1:0]ram[0:RD-1];
	
    
//    //-------------------上板------------------------
//    wire myclk;
//    reg clk_key;
//    integer f = 32'd500_0000; // halfT=50ms
//    fdivider fdivider01(.clk(clk),.f(f),.myclk(myclk));
//    reg last;
//    always@(posedge myclk) last <= key;
//    always@(*) clk_key <= (key==last)?key:0;
     // -------------------仿真------------------------
     wire clk_key;
     assign clk_key = clk;
    
    // 初始化
    // synopsys_translate_off
    integer i;
    initial begin
        for(i=0;i<RD;i=i+1) 
            ram[i]={DW{1'bz}};
    end
    // synopsys_translate_on

    // 读
    reg [DW-1:0]dout;
    always@(posedge clk_key) begin
        if(ren && ~rempty) begin 
            dout <= ram[raddr];
            // 每读一次，就pop()数据，之后数据为0
            // ram[raddr] <= {DW{1'bz}}; 
        end
        else dout <= {DW{1'bz}};
        // else dout <= dout;
    end

    // 写
    always@(posedge clk_key,posedge rst) begin
        if(rst) begin
            for(i=0;i<RD;i=i+1) 
                ram[i] <= {DW{1'bz}}; // 按位宽取结果，比直接的8'hzz合理
        end
        else if(wen && ~wfull) ram[waddr]<=din;
        else ram[waddr] <= ram[waddr];
    end

    // raddr移动
    always@(posedge clk_key,posedge rst) begin
        if(rst) raddr <= 1'd0;
        else if(ren && ~rempty) raddr <= raddr + 1'b1;
        else raddr <= raddr;
    end

    // waddr移动
    always@(posedge clk_key,posedge rst) begin
        if(rst) waddr <= 1'd0;
        else if(wen && ~wfull) waddr <= waddr + 1'b1;
        else waddr <= waddr;
    end
    

    // 内置计数
    always@(posedge clk_key,posedge rst) begin
        if(rst) cnt <= 1'd0;
        else if(wen && ~wfull && ren && ~rempty) cnt <= cnt; // 同时读写，避免cnt计算冲突
        else if(wen && ~wfull) cnt <= cnt + 1'd1;
        else if(ren && ~rempty) cnt <= cnt - 1'd1;
        else cnt <= cnt;
    end

    // 空满检测
    assign wfull = (cnt==RD)?1'b1:1'b0;
    assign rempty = (cnt==0)?1'b1:1'b0;
    
    // 结果显示
    wire [15:0]data={cnt,dout};
    display display01(.clk(clk),.data(data),
       .sm_wei(res_wei),.sm_duan(res_duan));
       
endmodule