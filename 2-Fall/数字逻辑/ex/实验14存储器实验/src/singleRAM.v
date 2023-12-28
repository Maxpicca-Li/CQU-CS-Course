`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/24 01:35:48
// Design Name: 
// Module Name: singleRAM
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


module singleRAM
#(parameter AW=4,DW=8)
(clk,rst,we,addr,data_in,res_wei,res_duan);
    input clk,rst,we; // 时钟信号，读写切换
    input [AW-1:0]addr;
    input [DW-1:0]data_in;
    output [3:0]res_wei;
    output [6:0]res_duan;
    wire clk_1Hz; // 时钟分频
    
    //--------------------上板--------------------------------
    integer f = 32'd5000_0000; // 1Hz
    fdivider fdivider01(.clk(clk),.f(f),.myclk(clk_1Hz)); 
//    //--------------------仿真-------------------------------
//    assign clk_1Hz = clk;
    
    localparam RD = 1 << AW;
    reg [DW-1:0]ram[0:RD-1];
    // 初始化，下列注释在仿真中执行、综合中不执行
    // synopsys_translate_off
    integer i;
    initial begin
        for(i=0;i<RD;i=i+1) 
            ram[i]=8'hzz;
    end
    // synopsys_translate_on
    
    // 同步写
    always@(posedge clk,posedge rst) begin
        if(rst) begin
            for(i=0;i<RD;i=i+1) 
                ram[i]<=8'h00;
        end
        else begin
            if(we) begin
                ram[addr] <= data_in;
            end
            else begin
                ram[addr] <= ram[addr];
            end
        end
    end
    
    // 同步读
    reg [DW-1:0]dout_syn;
    always@(posedge clk_1Hz) begin
        if(~we) begin
            dout_syn <= ram[addr];
        end
        else begin
            dout_syn <= 8'hzz;
        end
    end
    
    // 异步读
    reg [DW-1:0]dout_asyn;
    always@(*) begin
        if(~we) begin
            dout_asyn <= ram[addr];
        end
        else begin
            dout_asyn <= 8'hzz;
        end
    end
    
    // 结果显示
    wire [15:0]data;
    assign data={dout_asyn,dout_syn};
    display display01(clk,data,res_wei,res_duan);
    
endmodule