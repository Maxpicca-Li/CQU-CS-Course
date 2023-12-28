`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/17 09:25:31
// Design Name: 
// Module Name: calculator
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


module calculator(clk,clear,cal,sw,in,in_data,sm_wei,sm_duan);
    input clk; // ϵͳĬ��ʱ��CLOCK �˿�W5
    input clear; // ��Ҫһ����������ź�clear
    input cal; // �������ѡ��
    input [3:0]in; // in[3]������ʹ���źţ�in[2]������x����y��in[1:0]:��������Ķε�8λ���ݣ���4��
    input [1:0]sw; // ���أ�ѡ����Ҫ��ʾ������
    input [7:0]in_data; 
    output [3:0]sm_wei; // ������һ���������ʾ
    output [6:0]sm_duan; // ��������ܵ���ʾ����  
    
//------------��һ��������------------
    //���ݼ�¼
    reg [31:0]x;
    reg [31:0]y;
    always@(clear,in)begin
        if(clear) begin x=63'b0; y=63'b0; end 
        else if(in[3]) begin
            if(in[2])
                case(in[1:0])
                    2'b00:  begin x[7:0]=in_data[7:0]; end
                    2'b01:  begin x[15:8]=in_data[7:0]; end
                    2'b11:  begin x[23:16]=in_data[7:0]; end
                    2'b10:  begin x[31:24]=in_data[7:0]; end
                endcase
            else
                case(in[1:0])
                    2'b00:  begin y[7:0]=in_data[7:0]; end
                    2'b01:  begin y[15:8]=in_data[7:0]; end
                    2'b11:  begin y[23:16]=in_data[7:0]; end
                    2'b10:  begin y[31:24]=in_data[7:0]; end
                endcase      
        end
    end
    
//---------�ڶ���������������ϣ���ʼ����----------
    reg [63:0]res; // ����ݴ棬����Ҫ����ֵ
    wire [63:0]mf;
    wire [31:0]df;
    wire [31:0]re;
    multi multi0(.x(x),.y(y),.f(mf));
    divide divide0(.x(x),.y(y),.f(df),.re(re));
    always@(*)begin  // ��׽inend��cal,mf,df�ı仯
        if(cal) res = mf[63:0];
        else res[31:0] = df[31:0];  // res = {df,re};     
    end
    
//-----------���������������ѡ��--------
    reg [15:0]data;
    always@(*)// ��׽�仯����Ҫsw,res
        case(sw)
            2'b00:data[15:0]=res[15:0];
            2'b01:data[15:0]=res[31:16];
            2'b11:data[15:0]=res[47:32];
            2'b10:data[15:0]=res[63:48];
        endcase
    smg_ip_model display0(clk,data,sm_wei,sm_duan);
//    task multi;
//        input [31:0]x;
//        input [31:0]y;
//        output reg [63:0]f;
//        reg [63:0]tx;
//        integer i;
//        begin
//            f = 64'b0;
//            tx = x;
//            for(i=0;i<=31;i=i+1) begin
//                if(y[i] == 1'b1) f = f + tx;
//                tx = tx << 1; 
//            end
//        end
//    endtask
    
//    task divide;
//        input [31:0]x;
//        input [31:0]y;
//        output reg [31:0]f;
//        output reg [31:0]re; 
//        integer i;
//        begin
//            re = 32'b0;
//            f = 32'b0;
//            for(i=31;i>=0;i=i-1) begin
//                re = re << 1;
//                re = re + x[i];
//                f = f << 1;
//                if(re >= y) begin
//                    re = re - y;
//                    f = f + 1'b1;
//                end
//            end
//        end 
//    endtask
           
endmodule
