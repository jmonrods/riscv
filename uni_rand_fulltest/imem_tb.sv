// Instituto Tecnológico de Costa Rica
// Intel RFP
// Author:      Juan José Montero Rodríguez
// Date:        20.09.2024
// Description: RISC-V Instruction Randomizer

`timescale 1ns/1ps

module imem_tb();

	logic [31:0] addr;
	logic [31:0] instr;

	imem imem1(
		.A  (addr),
		.RD (instr)
	);
	
	initial begin
	
		addr = 32'h00400000;
		forever #10 addr = addr + 4;
	
	end

endmodule

