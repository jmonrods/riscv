`timescale 1ns/1ps

// bus functional model of the CPU
interface cpu_bfm;

    import cpu_pkg::*;
    `include "cpu_macros.svh"

    logic clk, rst;
    logic [31:0] pc;
    logic [31:0] instr;
    logic [31:0] result;

    initial begin
        clk = 1;
        forever begin
            #5;
            clk = ~clk;
        end
    end

    task reset_cpu();
        
        rst = 1;
        @(posedge clk);
        rst = 0;

    endtask : reset_cpu

    task send_instruction(input op_e operation, input data_s data);

        case (operation)
            ADDI:
            begin
                data.opcode = 7'b0010011;
                data.funct3 = 3'b000;
                data.funct7 = 7'b0000000;
                instr = {data.imm,data.rs1,data.funct3,data.rd,data.opcode};
            end
            ADD:
            begin
                data.opcode = 7'b0110011;
                data.funct3 = 3'b000;
                data.funct7 = 7'b0000000;
                instr  = {data.funct7,data.rs2,data.rs1,data.funct3,data.rd,data.opcode};
            end
            SUB:
            begin
                data.opcode = 7'b0110011;
                data.funct3 = 3'b000;
                data.funct7 = 7'b0100000;
                instr = {data.funct7,data.rs2,data.rs1,data.funct3,data.rd,data.opcode};
            end
            AND:
            begin
                data.opcode = 7'b0110011;
                data.funct3 = 3'b111;
                data.funct7 = 7'b0000000;
                instr = {data.funct7,data.rs2,data.rs1,data.funct3,data.rd,data.opcode};
            end
            OR:
            begin
                data.opcode = 7'b0110011;
                data.funct3 = 3'b110;
                data.funct7 = 7'b0000000;
                instr = {data.funct7,data.rs2,data.rs1,data.funct3,data.rd,data.opcode};
            end
            SLT:
            begin
                data.opcode = 7'b0110011;
                data.funct3 = 3'b010;
                data.funct7 = 7'b0000000;
                instr = {data.funct7,data.rs2,data.rs1,data.funct3,data.rd,data.opcode};
            end
        endcase

        @(posedge clk);

    endtask : send_instruction

endinterface
