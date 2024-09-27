package cpu_pkg;

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
