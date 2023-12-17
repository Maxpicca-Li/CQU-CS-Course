`timescale 1ns/1ps
// shift left 2bit
module sl2 (
    input wire[31:0]a,
    input wire[31:0]y
);
    assign y = {a[29:0],2'b00};  
endmodule