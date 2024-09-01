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

    wire [31:0] PC;
    wire [31:0] PCNext;
    wire [31:0] PCPlus4;
    wire [31:0] PCTarget;
    wire [31:0] Instr;
    wire [1:0]  ImmSrc;
    wire [31:0] ImmExt;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire        PCSrc;
    wire        ALUSrc;
    wire        ResultSrc;
    wire [2:0]  ALUControl;
    wire [31:0] ALUResult;
    wire [31:0] Result;
    wire        MemWrite;
    wire [31:0] WriteData;

    pc pc1 (
        .clk(clk),
        .rst(rst),
        .PCNext(PCNext),
        .PC(PC)
    );

    mux32 mux_pc (
        .sel(PCSrc),
        .A(PCPlus4),
        .B(PCTarget),
        .Q(PCNext)
    );

    adder32 pc_plus_4_adder (
        .A(PC),
        .B(4),
        .Q(PCPlus4)
    );

    imem imem1 (
        .A(PC),
        .RD(Instr)
    );

    register_bank rb1 (
        .clk(clk),
        .rst(rst),
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .WE3(),
        .WD3(Result),
        .RD1(SrcA),
        .RD2(WriteData)
    );

    Extend ext1 (
        .src(ImmSrc),
        .A(Instr[31:0]),
        .Q(ImmExt)
    );

    adder32 pc_target_adder (
        .A(PC),
        .B(ImmExt),
        .Q(PCTarget)
    );

    mux32 mux1 (
        .sel(ALUSrc),
        .A(WriteData),
        .B(ImmExt),
        .Q(SrcB)
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
        .WE(MemWrite),
        .A(ALUResult),
        .WD(WriteData),
        .RD(ReadData)
    );

    mux32 mux2 (
        .sel(ResultSrc),
        .A(ALUResult),
        .B(ReadData),
        .Q(Result)
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
        if (rst) PC <= 32'h00400000; // text segment
        else PC <= PCNext;
    end

endmodule


module adder32 (
    input        [31:0] A,
    input        [31:0] B,
    output logic [31:0] Q
);

    assign Q = A + B;

endmodule


// Instruction Memory
// ROM (aligned by 4)
module imem(
    input [31:0] A,
    output logic [31:0] RD
);

    always_comb begin
        case (A) // instructions in machine language
            32'h00400000: RD = 32'hFFC4A303; // lw x6, -4(x9)
            32'h00400004: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400008: RD = 32'h0062E233; // or x4, x5, x6
            32'h00400012: RD = 32'hFE420AE3; // beq x4, x4, L7
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

    // array of static memory
    logic [31:0] mem[32];

    // reset logic
    int i;
    always_ff @ (posedge rst) begin
        for (i = 0; i<32; i++) begin
            mem[i] <= 0;            
        end
    end

    // write logic
    always_ff @ (posedge clk) begin
        if (WE3) mem[A3] <= WD3;
    end

    // read logic
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

    // associative array: dynamic memory
    logic [31:0] mem [logic [31:0]];

    // reset logic
    always @(posedge rst) begin
        mem.delete();
    end

    // write logic
    always @(posedge clk) begin
        if (WE) begin
            mem[A] = WD;
        end
    end

    // read logic
    always @(posedge clk) begin
        RD = mem[A];
    end

endmodule


// Sign extension
module Extend(
    input        [1:0]  src,
    input        [31:0] A,
    output logic [31:0] Q
);

    always_comb begin

        case (src)
            2'b00:   Q = {{20{A[31]}}, A[31:20]};              // I-Type
            2'b01:   Q = {{20{A[31]}}, A[31:25], A[11:7]};     // S-Type
            2'b10:   Q = {{19{A[31]}}, A[31], A[7],A[30:25], A[11:8], 1'b0}; // B-Type
            default: Q = 32'h00000000; // not used
        endcase

    end

endmodule


// 32-bit ALU (Behavioral)
// Each operation needs to be replaced with proper hardware
module ALU(
    input [2:0] Ctrl,
    input [31:0] SrcA,
    input [31:0] SrcB,
    output logic [31:0] Result
);

    always_comb begin

        case (Ctrl)
            3'b000:  Result = SrcA + SrcB;              // add
            3'b001:  Result = SrcA - SrcB;              // subtract
            3'b010:  Result = SrcA && SrcB;             // and
            3'b011:  Result = SrcA || SrcB;             // or
            3'b101:  Result = (SrcA < SrcB) ? 1 : 0;    // slt (set if less than)
            default: Result = 32'hDEADBEEF;             // error
        endcase

    end

endmodule


module mux32 (
    input               sel,
    input        [31:0] A,
    input        [31:0] B,
    output logic [31:0] Q 
);

    assign Q = sel ? B : A;

endmodule
