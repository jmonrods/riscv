// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       26.08.2024
// Descripción: RISC-V CPU from Harris & Harris

`timescale 1ns/1ps

module cpu(
    input clk,
    input rst,
    output [31:0] ReadData
);

    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] Instr;
    wire [31:0] ImmExt;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    assign SrcB = ImmExt; // for now
    wire [31:0] ALUResult;

    pc pc1 (
        .clk(clk),
        .rst(rst),
        .PCNext(pc_next),
        .PC(pc)
    );

    imem imem1 (
        .A(pc),
        .RD(Instr)
    );

    register_bank rb1 (
        .clk(clk),
        .rst(rst),
        .A1(Instr[19:15]),
        .A2(),
        .A3(),
        .WE3(),
        .WD3(ReadData),
        .RD1(SrcA),
        .RD2()
    );

    Extend ext1 (
        .A(Instr[31:20]),
        .Q(ImmExt)
    );

    ALU alu1 (
        .Ctrl(ALUControl),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Result(ALUResult)
    );

    dmem dmem1 (
        .clk(clk),
        .rst(rst),
        .WE(),
        .A(ALUResult),
        .WD(),
        .RD(ReadData)
    );

endmodule


// Program Counter
module pc( 
    input               clk,
    input               rst,
    input        [31:0] PCNext,
    output logic [31:0] PC
);

    always_ff @ (posedge clk) begin
        if (rst) PC <= 32'h10000000; // begin of text segment
        else PC <= PCNext;
    end

    assign PCNext = PC + 4;

endmodule


// Instruction Memory
// ROM (aligned by 4)
module imem(
    input [31:0] A,
    output logic [31:0] RD
);

    always_comb begin
        case A: // code a program in machine language
            32'h00000000: RD = 32'hFFC4A303; // lw x6, -4(x9)
            32'h00000004: RD = 32'hFFC4A303; // lw x6, -4(x9)
            default:      RD = 32'hDEADBEEF; // error: pc out of bounds
        endcase
    end

endmodule


// Register Bank
module register_bank(
    input clk,
    input rst,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    logic [31:0] mem[32];

    always_ff @ (posedge rst) begin
        mem
    end

    always_ff @ (posedge clk) begin
        if (WE3) mem[A3] <= WD3;
        else WD3 <= WD3;
    end

    always_ff @ (posedge clk) begin
        RD1 <= mem[A1];
        RD2 <= mem[A2];
    end

endmodule


// Data Memory
// RAM (aligned by 4)
module dmem(
    input clk,
    input rst,
    input WE,
    input [31:0] A,
    input [31:0] WD,
    output logic [31:0] RD
);

// Note: avoid coding a 4GB RAM, takes forever to simulate
// Better: dictionary with keys, non-synthesizable (associative array)

    logic [31:0] mem [logic [31:0]]; // associative array of logic [31:0], indexed by logic [31:0]

    always @(posedge rst) begin
        mem.delete();
        // preload some values for testing
    end

    always @(posedge clk) begin
        if (WE) begin
            mem[A] <= WD;
            RD <= mem[A];
        end else begin
            RD <= mem[A];
        end
    end

endmodule


// Sign extension
module Extend(
    input  [11:0] A,
    output [31:0] Q
);

    assign Q = {20{A[11]}, A};

endmodule


// 32-bit ALU (Behavioral)
// Each operation needs to be replaced with proper hardware
module ALU(
    input [2:0] Ctrl,
    input SrcA,
    input SrcB,
    output Result
);

    always_comb begin

        case Ctrl:
            3'b000:  Result = SrcA + SrcB;   // add
            3'b001:  Result = SrcA - SrcB;   // subtract
            3'b010:  Result = SrcA && SrcB;  // and
            3'b011:  Result = SrcA || SrcB;  // or
            3'b101:  Result = SrcA << 1;     // slt
            default: Result = 32'bDEADBEEF; // error
        endcase

    end

endmodule
