// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       26.08.2024
// Descripción: RISC-V CPU from Harris & Harris

`timescale 1ns/1ps

module cpu (
    input clk,
    input rst,
    output [31:0] Result
);

    // Bus signals
    wire [31:0] PC;
    wire [31:0] PCNext;
    wire [31:0] PCPlus4;
    wire [31:0] PCTarget;
    wire [31:0] Instr;
    wire [31:0] ImmExt;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] ALUResult;
    wire [31:0] ReadData;
    wire [31:0] WriteData;

    // Control signals
    wire        PCSrc;
    wire        ResultSrc;
    wire        MemWrite;
    wire [2:0]  ALUControl;
    wire        ALUSrc;
    wire [1:0]  ImmSrc;
    wire        RegWrite;
    wire        zero;


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
        .WE3(RegWrite),
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
        .Result(ALUResult),
        .zero(zero)
    );

    dmem dmem1 (
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .RE(ResultSrc),
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

    control_unit ctrl1 (
        .op           (Instr[6:0]),
        .funct3       (Instr[14:12]),
        .funct7_bit5  (Instr[30]),
        .Zero         (zero),
        .PCSrc        (PCSrc),
        .ResultSrc    (ResultSrc),
        .MemWrite     (MemWrite),
        .ALUControl   (ALUControl),
        .ALUSrc       (ALUSrc),
        .ImmSrc       (ImmSrc),
        .RegWrite     (RegWrite)
    );

endmodule


// Program Counter
module pc ( 
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
module imem (
    input [31:0] A,
    output logic [31:0] RD
);

    always_comb begin
        case (A) // instructions in machine language
            32'h00400000: RD = 32'h00400413; // addi x8, x0, 4
            32'h00400004: RD = 32'h00600493; // addi x9, x0, 6
            32'h00400008: RD = 32'h00940933; // add x18, x8, x9
            32'h0040000C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400010: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400014: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400018: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040001C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400020: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400024: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400028: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040002C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400030: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400034: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400038: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040003C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400040: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400044: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400048: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040004C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400050: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400054: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400058: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040005C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400060: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400064: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400068: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040006C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400070: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400074: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400078: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040007C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400080: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400084: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400088: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040008C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400090: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400094: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h00400098: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h0040009C: RD = 32'h0064A423; // sw x6, 8(x9)
            32'h004000A0: RD = 32'h0064A423; // sw x6, 8(x9)
            default:      RD = 32'hDEADBEEF; // error: pc out of bounds
        endcase
    end

endmodule


// Register Bank
module register_bank (
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
    always_ff @(posedge clk) begin
        if (rst) for (i = 0; i<32; i++) mem[i] <= 0;
    end

    // write logic
    always_ff @ (posedge clk) begin
        if (WE3 & !rst) mem[A3] <= WD3;
    end

    // read logic
    always_ff @ (posedge clk) begin
        if (rst) begin
            RD1 <= 0;
            RD2 <= 0;
        end else begin
            RD1 <= mem[A1];
            RD2 <= mem[A2];
        end
    end

endmodule


// Data Memory
// RAM (aligned by 4)
module dmem (
    input clk,
    input rst,
    input WE,
    input RE,
    input [31:0] A,
    input [31:0] WD,
    output logic [31:0] RD
);

    // associative array: dynamic memory
    logic [31:0] mem [logic [31:0]];

    // reset logic
    always_ff @(posedge clk) begin
        if (rst) mem.delete();
    end

    // write logic
    always_ff @(posedge clk) begin
        if (WE & !rst) begin
            mem[A] = WD;
        end
    end

    // read logic
    always_ff @(posedge clk) begin
        if (RE & !rst) RD = mem[A];
    end

endmodule


// Sign extension
module Extend (
    input        [1:0]  src,
    input        [31:0] A,
    output logic [31:0] Q
);

    always_comb begin

        case (src)
            2'b00:   Q = {{20{A[31]}}, A[31:20]};              // I-Type
            2'b01:   Q = {{20{A[31]}}, A[31:25], A[11:7]};     // S-Type
            2'b10:   Q = {{19{A[31]}}, A[31], A[7],A[30:25], A[11:8], 1'b0}; // B-Type
            default: Q = 32'hDEADBEEF; // error
        endcase

    end

endmodule


// 32-bit ALU (Behavioral)
// Each operation needs to be replaced with proper hardware
module ALU (
    input        [2:0]  Ctrl,
    input        [31:0] SrcA,
    input        [31:0] SrcB,
    output logic [31:0] Result,
    output logic        zero
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

    assign zero = (Result == 0) ? 1 : 0;

endmodule


module mux32 (
    input               sel,
    input        [31:0] A,
    input        [31:0] B,
    output logic [31:0] Q 
);

    assign Q = sel ? B : A;

endmodule


module control_unit (
    input        [6:0] op,
    input        [2:0] funct3,
    input              funct7_bit5,
    input              Zero,
    output logic       PCSrc,
    output logic       ResultSrc,
    output logic       MemWrite,
    output logic [2:0] ALUControl,
    output logic       ALUSrc,
    output logic [1:0] ImmSrc,
    output logic       RegWrite
);

    // Main Decoder
    logic [1:0] ALUOp;
    logic       Branch;

    always_comb begin

        case (op[6:0])
            3: // lw
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 1'b1;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b1;
            end
            35: // sw
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 1'b0;
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ImmSrc    = 2'b01;
                RegWrite  = 1'b0;
            end
            51: // R-type
            begin
                ALUOp     = 2'b10;
                Branch    = 1'b0;
                ResultSrc = 1'b0;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b1;
            end
            99: // beq
            begin
                ALUOp     = 2'b01;
                Branch    = 1'b1;
                ResultSrc = 1'b0;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b10;
                RegWrite  = 1'b0;
            end
            19: // I-type
            begin
                ALUOp     = 2'b10;
                Branch    = 1'b0;
                ResultSrc = 1'b0;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b1;
            end
            default: // not implemented
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 1'b0;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b0;
            end
        endcase

    end

    assign PCSrc = Branch && Zero;


    // ALU Decoder

    always_comb begin

        case ({ALUOp,funct3,op[5],funct7_bit5})
            7'b00xxxxx: ALUControl = 3'b000;
            7'b01xxxxx: ALUControl = 3'b001;
            7'b1000000: ALUControl = 3'b000;
            7'b1000001: ALUControl = 3'b000;
            7'b1000010: ALUControl = 3'b000;
            7'b1000011: ALUControl = 3'b001;
            7'b10010xx: ALUControl = 3'b101;
            7'b10110xx: ALUControl = 3'b011;
            7'b10111xx: ALUControl = 3'b010;
            default:    ALUControl = 3'b000;
        endcase

    end

endmodule
