`timescale 1ns/1ps
module controller (
    input wire clk,rst,flushE,flushM,
    input wire [31:0]instrD,
    output wire regwriteW,regdstE,alusrcE,branchD,branchM,memWriteM,memtoRegW,jumpD,
    // 数据冒险添加信号
    output wire regwriteE,regwriteM,memtoRegE,memtoRegM, // input wire 
    output wire [2:0]alucontrolE
);

    wire [1:0]aluop;
    wire [6:0]signsD,signsE,signsM,signsW;
    wire [2:0]alucontrolD;
    wire ena,clear;
    
    assign ena = 1'b1;
    assign clear = 1'b0;

    // assign {regwrite,regdst,alusrc,branch,memWrite,memtoReg,aluop,jump} = temp;
    // signsD = {6regwrite,5regdst,4alusrc,3branch,2memWrite,1memtoReg,0jump}
    assign regwriteW = signsW[6];
    assign regwriteE = signsE[6];
    assign regwriteM = signsM[6];
    assign regdstE = signsE[5];
    assign alusrcE = signsE[4];
    assign branchD = signsD[3];
    assign branchM = signsM[3];
    assign memWriteM = signsM[2];
    assign memtoRegW = signsW[1];
    assign memtoRegE = signsE[1];
    assign memtoRegM = signsM[1];
    assign jumpD = signsD[0];

    // Decoder
    main_dec main_dec(.op(instrD[31:26]),.signs(signsD),.aluop(aluop));
    alu_dec alu_dec(.aluop(aluop),.funct(instrD[5:0]),.alucontrol(alucontrolD));

    flopenrc #(3) DFF_alucontrolE(clk,rst,flushE,ena,alucontrolD,alucontrolE);
    flopenrc #(7) DFF_signsE     (clk,rst,flushE,ena,signsD,signsE);
    flopenrc #(7) DFF_signsM     (clk,rst,flushM,ena,signsE,signsM);
    flopenrc #(7) DFF_signsW     (clk,rst,clear ,ena,signsM,signsW);

endmodule


module main_dec (
    input wire[5:0]op,
    // output wire regwrite,regdst,alusrc,branch,memWrite,memtoReg,jump,
    output wire [6:0]signs,
    output wire [1:0]aluop
);
    wire [8:0]temp;
    assign  temp =  (op==6'b000000) ? 9'b110000_10_0: // R-type 最后一位是jump
                    (op==6'b100011) ? 9'b101001_00_0: // lw
                    (op==6'b101011) ? 9'b001010_00_0: // sw
                    (op==6'b000100) ? 9'b000100_01_0: // beq
                    (op==6'b001000) ? 9'b101000_00_0: // addi
                    (op==6'b000010) ? 9'b000000_00_1: // j
                    9'b000000000; // 注意：这里的X信号，全部视为0
    // assign {regwrite,regdst,alusrc,branch,memWrite,memtoReg,aluop,jump} = temp;
    assign {signs[6:1],aluop,signs[0]} = temp;
endmodule


module alu_dec (
    input wire[1:0]aluop,
    input wire[5:0]funct,
    output wire[2:0]alucontrol
);
    assign alucontrol = (aluop==2'b00) ? 3'b010: // add
                        (aluop==2'b01) ? 3'b110: // sub
                        (aluop==2'b10) ? 
                            (funct==6'b100000) ? 3'b010:
                            (funct==6'b100010) ? 3'b110:
                            (funct==6'b100100) ? 3'b000: // and
                            (funct==6'b100101) ? 3'b001: // or
                            (funct==6'b101010) ? 3'b111: // slt
                            3'b000:
                        3'b000; // default
endmodule