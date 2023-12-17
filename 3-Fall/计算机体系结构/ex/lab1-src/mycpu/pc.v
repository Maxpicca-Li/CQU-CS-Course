`timescale 1ns/1ps
// PC模块，一个D触发器
module pc (
    input wire clk,rst,ena,flush,
    input wire[31:0]dactual,
    input wire[31:0]din,

    output reg[31:0]dout
);
    initial begin
        dout <= 32'b0;
    end
    always @(posedge clk) begin
        if(rst) dout <= 32'b0;
        else if(flush) dout <= dactual; 
        else if(ena) dout <= din;
    end
endmodule