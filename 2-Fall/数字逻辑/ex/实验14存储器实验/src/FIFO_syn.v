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
	
    // �����ź�
	reg [AW-1:0]waddr=1'b0,raddr=1'b0;
	reg [AW:0]cnt = 1'b0; // ��AW=4,��cnt����17��״̬��0���գ�~16������
	reg [DW-1:0]ram[0:RD-1];
	
    
//    //-------------------�ϰ�------------------------
//    wire myclk;
//    reg clk_key;
//    integer f = 32'd500_0000; // halfT=50ms
//    fdivider fdivider01(.clk(clk),.f(f),.myclk(myclk));
//    reg last;
//    always@(posedge myclk) last <= key;
//    always@(*) clk_key <= (key==last)?key:0;
     // -------------------����------------------------
     wire clk_key;
     assign clk_key = clk;
    
    // ��ʼ��
    // synopsys_translate_off
    integer i;
    initial begin
        for(i=0;i<RD;i=i+1) 
            ram[i]={DW{1'bz}};
    end
    // synopsys_translate_on

    // ��
    reg [DW-1:0]dout;
    always@(posedge clk_key) begin
        if(ren && ~rempty) begin 
            dout <= ram[raddr];
            // ÿ��һ�Σ���pop()���ݣ�֮������Ϊ0
            // ram[raddr] <= {DW{1'bz}}; 
        end
        else dout <= {DW{1'bz}};
        // else dout <= dout;
    end

    // д
    always@(posedge clk_key,posedge rst) begin
        if(rst) begin
            for(i=0;i<RD;i=i+1) 
                ram[i] <= {DW{1'bz}}; // ��λ��ȡ�������ֱ�ӵ�8'hzz����
        end
        else if(wen && ~wfull) ram[waddr]<=din;
        else ram[waddr] <= ram[waddr];
    end

    // raddr�ƶ�
    always@(posedge clk_key,posedge rst) begin
        if(rst) raddr <= 1'd0;
        else if(ren && ~rempty) raddr <= raddr + 1'b1;
        else raddr <= raddr;
    end

    // waddr�ƶ�
    always@(posedge clk_key,posedge rst) begin
        if(rst) waddr <= 1'd0;
        else if(wen && ~wfull) waddr <= waddr + 1'b1;
        else waddr <= waddr;
    end
    

    // ���ü���
    always@(posedge clk_key,posedge rst) begin
        if(rst) cnt <= 1'd0;
        else if(wen && ~wfull && ren && ~rempty) cnt <= cnt; // ͬʱ��д������cnt�����ͻ
        else if(wen && ~wfull) cnt <= cnt + 1'd1;
        else if(ren && ~rempty) cnt <= cnt - 1'd1;
        else cnt <= cnt;
    end

    // �������
    assign wfull = (cnt==RD)?1'b1:1'b0;
    assign rempty = (cnt==0)?1'b1:1'b0;
    
    // �����ʾ
    wire [15:0]data={cnt,dout};
    display display01(.clk(clk),.data(data),
       .sm_wei(res_wei),.sm_duan(res_duan));
       
endmodule