`timescale 1ns / 1ps

module mips(
	input wire clk,rst,
	input wire[31:0] instr,data_ram_rdata, // 前in 后out
	output wire memWriteM, 
	output wire[31:0] pc,data_ram_waddrM,data_ram_wdataM
);
	wire [31:0]instrD;

	datapath datapath(
		clk,rst, // input wire 
		instr,data_ram_rdata, // input wire [31:0]
		
		memWriteM,
		instrD,pc,data_ram_waddrM,data_ram_wdataM // output wire [31:0]
	);
	
endmodule
