package cpu_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

    typedef enum {ADDI, ADD, SUB, AND, OR, SLT} op_e;

	typedef struct {
		logic [4:0]  rd;
		logic [4:0]  rs1;
		logic [4:0]  rs2;
		logic [6:0]  funct7;
		logic [2:0]  funct3;
		logic [6:0]  opcode;
		logic [11:0] imm;
	} data_s;

	`include "scoreboard.svh"
	`include "coverage.svh"
	`include "base_tester.svh"
	`include "random_tester.svh"
	`include "add_tester.svh"
	`include "env.svh"
	`include "random_test.svh"
	`include "add_test.svh"

endpackage
