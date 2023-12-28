`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/02 00:03:20
// Design Name: 
// Module Name: judgeFSM
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


module judgeFSM #(parameter DW = 8)(rst,btnclk,code,din,pass,fail);
    input rst,btnclk;
    input [DW-1:0]code;
    input [1:0]din;
    output reg pass;
    output reg fail;
    
    localparam [2:0]s0 = 3'b000,s1 = 3'b001,s2 = 3'b010,s3 = 3'b011,s4 = 3'b100,s5 = 3'b101, s6 = 3'b110;
    reg [2:0]curr=s0,next=s0;
    
    always@(negedge btnclk,posedge rst) begin
        if(rst) begin
            curr = s0; 
            next = s0; 
        end
        else begin
            case(curr)
                s0: next = (din[1:0]==code[7:6])? s1:s4;             
                s1: next = (din[1:0]==code[5:4])? s2:s5;
                s2: next = (din[1:0]==code[3:2])? s3:s6;
                s3: next = s0;
                s4: next = s5;
                s5: next = s6;
                s6: next = s0;
                default: next = s0; 
            endcase
            curr <= next;
        end
    end
    
    always@(negedge btnclk,posedge rst) begin
        if(rst) begin
            pass = 1'b0;
            fail = 1'b0;
        end 
        else begin
            if(curr==s3) begin
                if (din[1:0]==code[1:0]) begin pass = 1'b1;fail = 1'b0; end
                else begin pass = 1'b0;fail = 1'b1; end
            end
            else if(curr==s6) begin pass = 1'b0;fail = 1'b1; end
            else begin pass = 1'b0;fail = 1'b0; end
        end
    end
    
endmodule

