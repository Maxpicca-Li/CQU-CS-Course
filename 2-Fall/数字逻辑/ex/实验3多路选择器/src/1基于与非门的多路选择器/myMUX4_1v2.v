`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/08 02:50:29
// Design Name: 
// Module Name: myMUX4_1v2
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


module myMUX4_1v2(
    input s0,
    input s1,
    input x0,
    input x1,
    input x2,
    input x3,
    output y
    );
    wire ns0,ns1,y0,y1,y2,y3,y10,y23;
    notgate_0 ng0(s0,ns0);
    notgate_0 ng2(s1,ns1);
    andgate_0 ag0(ns0,ns1,x0,y0);
    andgate_0 ag1(s0,ns1,x1,y1);
    andgate_0 ag2(ns0,s1,x2,y2);
    andgate_0 ag3(s0,s1,x3,y3);
    orgate_0 og0(y0,y1,y10);
    orgate_0 og1(y2,y3,y23);
    orgate_0 og2(y10,y23,y);
endmodule
