// Instituto Tecnológico de Costa Rica
// Intel RFP
// Author:      Juan José Montero Rodríguez
// Date:        20.09.2024
// Description: RISC-V Instruction Randomizer
//              This module generates random valid RISC-V instructions

`timescale 1ns/1ps

// define macro for randomization check
`define SV_RAND_CHECK(r) \
    do begin \
        if (!(r)) begin \
            $display("%s:%d: Randomization failed \"%s\"", \
            `__FILE__, `__LINE__, `"r`"); \
            $finish(); \
        end \
    end while (0)


package riscv_asm;

	typedef enum {ADDI, ADD, SUB, AND, OR, SLT} op_e;
	
	class Instruction;
	
		rand op_e operation;
		
		rand logic [4:0] rd;
		rand logic [4:0] rs1;
		rand logic [4:0] rs2;
		
		logic [6:0] funct7;
		logic [2:0] funct3;
		logic [6:0] opcode;

		rand logic [11:0] imm;

		logic [31:0] instr;
		
		function void post_randomize();
			
			case (operation)
				ADDI:
				begin
					opcode = 7'b0010011;
					funct3 = 3'b000;
					funct7 = 7'b0000000;
					instr  = {imm,rs1,funct3,rd,opcode};
				end
				ADD:
				begin
					opcode = 7'b0110011;
					funct3 = 3'b000;
					funct7 = 7'b0000000;
					instr  = {funct7,rs2,rs1,funct3,rd,opcode};
				end
				SUB:
				begin
					opcode = 7'b0110011;
					funct3 = 3'b000;
					funct7 = 7'b0100000;
					instr  = {funct7,rs2,rs1,funct3,rd,opcode};
				end
				AND:
				begin
					opcode = 7'b0010011;
					funct3 = 3'b111;
					funct7 = 7'b0000000;
					instr  = {funct7,rs2,rs1,funct3,rd,opcode};
				end
				OR:
				begin
					opcode = 7'b0010011;
					funct3 = 3'b110;
					funct7 = 7'b0000000;
					instr  = {funct7,rs2,rs1,funct3,rd,opcode};
				end
				SLT:
				begin
					opcode = 7'b0010011;
					funct3 = 3'b010;
					funct7 = 7'b0000000;
					instr  = {funct7,rs2,rs1,funct3,rd,opcode};
				end
			endcase
			
		endfunction
		
		function void print_instr();
		
			case (operation)
				ADDI:    $display("%0s:\t%32b",operation.name(),instr);
				default: $display("%0s:\t%32b",operation.name(),instr); 
			endcase
		
		endfunction 
	
	endclass

endpackage


module imem(
	input        [31:0] A,
	output logic [31:0] RD
);

	import riscv_asm::*;

	Instruction in;
	
	// Covergroup checks if all opcodes were used
	covergroup CovInsOp;
		coverpoint in.operation;
	endgroup

	CovInsOp cv;

	initial begin

		in = new();
		cv = new();
			
	end


	always @(A) begin
	
		`SV_RAND_CHECK(in.randomize());
		
		cv.sample();

		RD = in.instr;
		
	end

endmodule
