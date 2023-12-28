`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Create Date: 2020/11/24 20:09:41
// Design Name:
// Module Name: double_ram
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


module double_ram
    #(parameter AW=4,DW=4,flag=1)(
         input rst,
         input clk,
         input we_a,
         input [DW-1:0] din_a,
         input [AW-1:0] addr_a,
         input we_b,
         input [DW-1:0] din_b,
         input [AW-1:0] addr_b,
         output [3:0]sm_wei, // 控制哪一个数码管显示
         output [6:0]sm_duan // 控制数码管的显示内容
     );
    parameter DP=1<<AW;     //深度
    reg [DW-1:0] mem[DP-1:0];
    reg [DW-1:0] reg_d_a;       //存储a端口的输出内容
    reg [DW-1:0] reg_d_b;       //存储b端口的输出内容
    reg busy_a=0;
    reg busy_b=0;
    wire myclk;

    //--------------------------上板与仿真-----------------------------
    if(flag) begin  // 上板
        integer f=32'd5000_0000; // halfT=0.5s
        fdivider fdivider01(.clk(clk),.f(f),.myclk(myclk));
    end
    else begin // 仿真
        assign myclk=clk;
    end

    //initialization
    //synopsys_translation_off
    integer i;
    initial begin
        for(i=0;i<DP;i=i+1) begin
            mem[i]=4'h0;
        end
    end
    //synopsys_translation_on

    always@(*) begin
        if(addr_a!=addr_b) begin       //地址不同时，无冲突
            busy_a=1;
            busy_b=1;
        end
        else begin         //地址相同，同时读写时，设置a端口优先于b端口
            if(we_a) begin
                busy_a=1;
                busy_b=0;
            end
            else if(we_b) begin
                busy_a=0;
                busy_b=1;
            end
            else begin
                busy_a=1;      //只要不是在写就为高电平
                busy_b=1;
            end
        end
    end

    //同步读
    always@(posedge myclk or posedge rst) begin // clk上板用1Hz，要fdivider
        if(rst) begin
            reg_d_a<=0;
        end
        else begin
            if(!we_a && busy_a) begin
                reg_d_a<=mem[addr_a];
            end
            else begin
                reg_d_a<=reg_d_a;
            end
        end
    end

    //异步读
    always@(*) begin
        if(rst) begin
            reg_d_b<=0;
        end
        if(!we_b && busy_b) begin
            reg_d_b<=mem[addr_b];
        end
        else begin
            reg_d_b<=reg_d_b;
        end
    end

    //write declaration
    always@(posedge myclk or posedge rst) begin
        if(rst)
            for(i=0;i<DP;i=i+1) begin
                mem[i]=4'h0;
            end
        else begin
            if(we_a && busy_a) begin
                mem[addr_a]<=din_a;
            end
            if (we_b && busy_b) begin        //用else if 的话，两个都有效，但是不在同一个地址上
                mem[addr_b]<=din_b;
            end
        end
        //         else begin
        //            mem[addr_a]<=mem[addr_a];            //导致其无法修改的原因
        //            mem[addr_b]<=mem[addr_b];
        //          end
    end

    wire [DW-1:0] dout_a;
    wire [DW-1:0] dout_b;
    assign dout_a=(!we_a)? reg_d_a:{DW{1'bz}};
    assign dout_b=(!we_b)? reg_d_b:{DW{1'bz}};
    wire [15:0] data={dout_b,dout_a};
    display display0(.clk(clk),.data(data),.sm_wei(sm_wei),.sm_duan(sm_duan));
endmodule
