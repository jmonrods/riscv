// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       26.08.2024
// Descripción: RISC-V CPU from Harris & Harris

`timescale 1ns/1ps

module cpu (
    input clk,
    input rst,
    input        [31:0] Instr,
    output logic [31:0] PC,
    output logic [31:0] Result
);

    // Bus signals
    wire [31:0] PC;
    wire [31:0] PCNext;
    wire [31:0] PCPlus4;
    wire [31:0] PCTarget;
    wire [31:0] ImmExt;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] ALUResult;
    wire [31:0] ReadData;
    wire [31:0] WriteData;

    // Control signals
    wire        PCSrc;
    wire [1:0]  ResultSrc;
    wire        MemWrite;
    wire [2:0]  ALUControl;
    wire        ALUSrc;
    wire [1:0]  ImmSrc;
    wire        RegWrite;
    wire        zero;


    pc pc1 (
        .clk    (clk),
        .rst    (rst),
        .PCNext (PCNext),
        .PC     (PC)
    );

    mux32 mux_pc (
        .sel    (PCSrc),
        .A      (PCPlus4),
        .B      (PCTarget),
        .Q      (PCNext)
    );

    adder32 pc_plus_4_adder (
        .A      (PC),
        .B      (4),
        .Q      (PCPlus4)
    );

    register_bank rb1 (
        .clk    (clk),
        .rst    (rst),
        .A1     (Instr[19:15]),
        .A2     (Instr[24:20]),
        .A3     (Instr[11:7]),
        .WE3    (RegWrite),
        .WD3    (Result),
        .RD1    (SrcA),
        .RD2    (WriteData)
    );

    Extend ext1 (
        .src    (ImmSrc),
        .A      (Instr[31:0]),
        .Q      (ImmExt)
    );

    adder32 pc_target_adder (
        .A      (PC),
        .B      (ImmExt),
        .Q      (PCTarget)
    );

    mux32 mux1 (
        .sel    (ALUSrc),
        .A      (WriteData),
        .B      (ImmExt),
        .Q      (SrcB)
    );

    alu alu1 (
        .ALUControl   (ALUControl),
        .A            (SrcA),
        .B            (SrcB),
        .Result       (ALUResult),
        .oVerflow     (),
        .Carry        (),
        .Negative     (),
        .Zero         (zero)
    );

    dmem dmem1 (
        .clk    (clk),
        .rst    (rst),
        .WE     (MemWrite),
        .RE     (ResultSrc[0]),
        .A      (ALUResult),
        .WD     (WriteData),
        .RD     (ReadData)
    );

    mux_alu_out mux_alu (
        .sel    (ResultSrc),
        .A      (ALUResult),
        .B      (ReadData),
        .C      (PCPlus4),
        .D      (),
        .Q      (Result)
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

    // write logic
    int i;
    always_ff @(posedge clk) begin
        if (rst) for (i = 0; i<32; i++) mem[i] <= 0;
	else if (WE3) mem[A3] <= WD3;
    end

    // read logic
    assign RD1 = (A1 == 0) ? 32'h00000000 : mem[A1];
    assign RD2 = (A2 == 0) ? 32'h00000000 : mem[A2];

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

    // write logic
    always_ff @(posedge clk) begin
        if (rst) mem.delete();
	else if (WE) mem[A] = WD;
    end

    // read logic
    always_ff @(posedge clk) begin
        if (RE & !rst) RD = mem[A];
        else           RD = 32'hDEADBEEF;
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
            2'b00:   Q = {{20{A[31]}}, A[31:20]};                            // I-Type
            2'b01:   Q = {{20{A[31]}}, A[31:25], A[11:7]};                   // S-Type
            2'b10:   Q = {{19{A[31]}}, A[31], A[7],A[30:25], A[11:8], 1'b0}; // B-Type
            2'b11:   Q = {{12{A[31]}}, A[19:12], A[20], A[30:21], 1'b0};     // J-Type
            default: Q = 32'hDEADBEEF; // error
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


module mux_alu_out (
    input        [1:0]  sel,
    input        [31:0] A,
    input        [31:0] B,
    input        [31:0] C,
    input        [31:0] D,
    output logic [31:0] Q 
);

    always_comb begin

        case (sel)
            2'b00:   Q = A;
            2'b01:   Q = B;
            2'b10:   Q = C;
            2'b11:   Q = D;
            default: Q = 0;
        endcase

    end

endmodule


module control_unit (
    input        [6:0] op,
    input        [2:0] funct3,
    input              funct7_bit5,
    input              Zero,
    output logic       PCSrc,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic [2:0] ALUControl,
    output logic       ALUSrc,
    output logic [1:0] ImmSrc,
    output logic       RegWrite
);

    // Main Decoder
    logic [1:0] ALUOp;
    logic       Branch;
    logic       Jump;

    always_comb begin

        case (op[6:0])
            3: // lw
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 2'b01;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b1;
                Jump      = 1'b0;
            end
            35: // sw
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 2'b00;
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ImmSrc    = 2'b01;
                RegWrite  = 1'b0;
                Jump      = 1'b0;
            end
            51: // R-type
            begin
                ALUOp     = 2'b10;
                Branch    = 1'b0;
                ResultSrc = 2'b00;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b1;
                Jump      = 1'b0;
            end
            99: // beq
            begin
                ALUOp     = 2'b01;
                Branch    = 1'b1;
                ResultSrc = 2'b00;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b10;
                RegWrite  = 1'b0;
                Jump      = 1'b0;
            end
            19: // I-type
            begin
                ALUOp     = 2'b10;
                Branch    = 1'b0;
                ResultSrc = 2'b00;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b1;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b1;
                Jump      = 1'b0;
            end
            111: // jal
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 2'b10;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b11;
                RegWrite  = 1'b1;
                Jump      = 1'b1;
            end
            default: // not implemented
            begin
                ALUOp     = 2'b00;
                Branch    = 1'b0;
                ResultSrc = 2'b00;
                MemWrite  = 1'b0;
                ALUSrc    = 1'b0;
                ImmSrc    = 2'b00;
                RegWrite  = 1'b0;
            end
        endcase

    end

    assign PCSrc = (Branch && Zero) || Jump;


    // ALU Decoder

    always_comb begin

        casez ({ALUOp,funct3,op[5],funct7_bit5})
            7'b00?????: ALUControl = 3'b000; // lw, sw
            7'b01?????: ALUControl = 3'b001; // beq
            7'b1000000: ALUControl = 3'b000; // add
            7'b1000001: ALUControl = 3'b000; // add
            7'b1000010: ALUControl = 3'b000; // add
            7'b1000011: ALUControl = 3'b001; // sub
            7'b10010??: ALUControl = 3'b101; // slt
            7'b10110??: ALUControl = 3'b011; // or
            7'b10111??: ALUControl = 3'b010; // and
            default:    ALUControl = 3'b000;
        endcase

    end

endmodule
