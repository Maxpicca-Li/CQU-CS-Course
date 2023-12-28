`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/24 20:48:16
// Design Name: 
// Module Name: display
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


module display(clk,data,sm_wei,sm_duan);
    input clk;
    input [15:0] data;
    output [3:0] sm_wei;
    output [6:0] sm_duan;
    // step1:��Ƶ    
    integer clk_cnt=1'b0;
    reg clk_400Hz=0; // �ǵó�ʼ����Ϊ0
    always@(posedge clk) begin
        if(clk_cnt==32'd100000) begin 
            clk_cnt<=1'b0;
            clk_400Hz<=~clk_400Hz;  // ������Ƶ1ms��һ��
        end
        else clk_cnt<=clk_cnt+1'b1;
    end
    
    // step2:λ���Ƶı仯�������λ���ƣ�
    reg[3:0] AN=4'b1110;  //��������1�򰵣�0���������ȱ���
    always@(posedge clk_400Hz) begin  // �ȴ���������Ҫ2ms,һ�����������滻��һ����ʾͣ��8ms
        AN <={AN[2:0],AN[3]}; 
    end
    
    // step3:�ο��ƣ�ÿһ���ο��Ƶ���Ϊ4λ
    reg[3:0] duan_ctrl;
    always@(*) begin
        case(AN)
            4'b1110:duan_ctrl=data[3:0];
            4'b1101:duan_ctrl=data[7:4];
            4'b1011:duan_ctrl=data[11:8];
            4'b0111:duan_ctrl=data[15:12];
            default:duan_ctrl=4'hf;
         endcase  
    end
    
    // step4:����ģ�飨�������ʾ���ƣ�
    reg[6:0] duan;
    always@(duan_ctrl) begin
        case(duan_ctrl)
            4'h0:duan=7'b100_0000;
            4'h1:duan=7'b111_1001;
            4'h2:duan=7'b010_0100;
            4'h3:duan=7'b011_0000;
            4'h4:duan=7'b001_1001;
            4'h5:duan=7'b001_0010;
            4'h6:duan=7'b000_0010;
            4'h7:duan=7'b111_1000;
            4'h8:duan=7'b000_0000;
            4'h9:duan=7'b001_0000;
            4'ha:duan=7'b000_1000;
            4'hb:duan=7'b000_0011;
            4'hc:duan=7'b100_0110;
            4'hd:duan=7'b010_0001;
            4'he:duan=7'b000_0110;
            4'hf:duan=7'b000_1110;
            default:duan=7'b111_1111;  
        endcase
    end     
    assign sm_wei = AN[3:0];
    assign sm_duan = duan[6:0];  
endmodule
