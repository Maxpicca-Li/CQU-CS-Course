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

// DW ����λ��DW/2, flag ���滹���ϰ�
module mimasuo#(parameter DW = 8,flag = 1)
(clk,rst,set,button,password,pass,fail,res_wei,res_duan);
    input clk,rst,set;
    input [3:0]button;
    input [(DW-1):0]password;
    output pass,fail;
    output[3:0]res_wei; // ��ʾ�Ѿ����������
    output[6:0]res_duan;
    
    // -------------------------��������---------------------
    wire [3:0]btn;
    if(flag) begin // �ϰ�
        debkey debkey01(.clk(clk),.rst(rst),.button(button),.btn(btn));
    end 
    else begin // ����
        assign btn = button;
    end
    
    //-----------------------------��ʼ����----------------------
    reg [DW-1:0]code;
    always@(*) begin
        if(rst) code = {DW{1'b1}};
        else if(set) code = password;
    end 
    
    //-----------------------------��������---------------------
    wire [1:0]din;
    wire [15:0]data;
    wire btnclk; // ���ð���ģ��ʱ��
    inputData #(.DW(DW)) inpurData01(.rst(rst),.btn(btn),.btnclk(btnclk),.din(din),.data(data));
    
    //----------------------------�����ʾ------------------------
    display display01(.clk(clk),.data(data),.sm_wei(res_wei),.sm_duan(res_duan));
    
    //----------------------------�����ж�-------------------------
    judgeFSM #(.DW(DW)) judgeFSM01(.rst(rst),.btnclk(btnclk),.code(code),
        .din(din),.pass(pass),.fail(fail));
endmodule
