`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/01 23:31:45
// Design Name: 
// Module Name: mimasuo
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

// DW 密码位宽DW/2, flag 仿真还是上板
module mimasuo#(parameter DW = 8,flag = 1)
(clk,rst,set,button,password,pass,fail,res_wei,res_duan);
    input clk,rst,set;
    input [3:0]button;
    input [(DW-1):0]password;
    output pass,fail;
    output[3:0]res_wei; // 显示已经输入的数字
    output[6:0]res_duan;
    
    // -------------------------按键防抖---------------------
    wire [3:0]btn;
    if(flag) begin // 上板
        debkey debkey01(.clk(clk),.rst(rst),.button(button),.btn(btn));
    end 
    else begin // 仿真
        assign btn = button;
    end
    
    //-----------------------------初始密码----------------------
    reg [DW-1:0]code;
    always@(*) begin
        if(rst) code = {DW{1'b1}};
        else if(set) code = password;
    end 
    
    //-----------------------------输入密码---------------------
    wire [1:0]din;
    wire [15:0]data;
    wire btnclk; // 内置按键模拟时钟
    inputData #(.DW(DW)) inpurData01(.rst(rst),.btn(btn),.btnclk(btnclk),.din(din),.data(data));
    
    //----------------------------结果显示------------------------
    display display01(.clk(clk),.data(data),.sm_wei(res_wei),.sm_duan(res_duan));
    
    //----------------------------密码判断-------------------------
    judgeFSM #(.DW(DW)) judgeFSM01(.rst(rst),.btnclk(btnclk),.code(code),
        .din(din),.pass(pass),.fail(fail));
endmodule
