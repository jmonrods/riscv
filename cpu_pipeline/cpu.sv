// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       16.10.2024
// Descripción: RISC-V Pipelined CPU from Harris & Harris

`timescale 1ns/1ps

module cpu (
    input        clk,
    input        rst,
    input [31:0] Instr,
    input [31:0] ReadData,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    output logic MemWrite,
    output logic [31:0] Result
);

    logic       PCSrc;
    logic [1:0] ResultSrcE;
    logic [1:0] ResultSrcW;
    logic [2:0] ALUControl;
    logic       ALUSrc;
    logic [1:0] ImmSrc;
    logic       RegWriteM;
    logic       RegWriteW;
    logic       zero;

    datapath data1 (
        .clk          (clk),
        .rst          (rst),
        .Instr        (Instr),
        .ReadData     (ReadData),
        .PCSrc        (PCSrc),
        .ResultSrc    (ResultSrcW),
        .ALUControl   (ALUControl),
        .ALUSrc       (ALUSrc),
        .ImmSrc       (ImmSrc),
        .RegWriteM    (RegWriteM),
        .RegWriteW    (RegWriteW),
        .ResultSrcE_0 (ResultSrcE[0]),
        .PC           (PC),
        .ALUResult    (ALUResult),
        .WriteData    (WriteData),
        .zero         (zero),
        .Result       (Result)
    );

    control ctrl1 (
        .clk         (clk),
        .rst         (rst),
        .op          (Instr[6:0]),
        .funct3      (Instr[14:12]),
        .funct7_bit5 (Instr[30]),
        .ZeroE       (zero),
        .PCSrc       (PCSrc),
        .ResultSrcE  (ResultSrcE),
        .ResultSrcW  (ResultSrcW),
        .MemWrite    (MemWrite),
        .ALUControl  (ALUControl),
        .ALUSrc      (ALUSrc),
        .ImmSrc      (ImmSrc),
        .RegWriteM   (RegWriteM),
        .RegWriteW   (RegWriteW)
    );

endmodule : cpu


module datapath (
    input               clk,
    input               rst,
    input        [31:0] Instr,
    input        [31:0] ReadData,
    input               PCSrc,
    input        [1:0]  ResultSrc,
    input        [2:0]  ALUControl,
    input               ALUSrc,
    input        [1:0]  ImmSrc,
    input               RegWriteM,
    input               RegWriteW,
    input               ResultSrcE_0,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    output logic        zero,
    output logic [31:0] Result
);

    logic [31:0] PCF;
    logic [31:0] InstrF;
    logic [31:0] PCPlus4F;
    logic [31:0] PCFprime;

    logic [31:0] InstrD;
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;
    logic  [4:0] RdD;
    logic [31:0] ImmExtD;
    logic [31:0] RD1D;
    logic [31:0] RD2D;

    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] SrcAE;
    logic [31:0] SrcBE;
    logic [31:0] PCE;
    logic  [4:0] Rs1E;
    logic  [4:0] Rs2E;
    logic  [4:0] RdE;
    logic [31:0] ImmExtE;
    logic [31:0] PCPlus4E;
    logic [31:0] ALUResultE;
    logic [31:0] WriteDataE;
    logic [31:0] PCTargetE;

    logic [31:0] ALUResultM;
    logic [31:0] WriteDataM;
    logic [31:0] ReadDataM;
    logic  [4:0] RdM;
    logic [31:0] PCPlus4M;

    logic [31:0] ALUResultW;
    logic [31:0] ReadDataW;
    logic [31:0] PCPlus4W;
    logic [31:0] ResultW;
    logic  [4:0] RdW;

    logic  [1:0] ForwardAE;
    logic  [1:0] ForwardBE;

    logic        StallF;
    logic        StallD;
    logic        FlushE;

    assign Result = ResultW;

    mux32 mux_pc_src (
        .sel (PCSrc),
        .A   (PCPlus4F),
        .B   (PCTargetE),
        .Q   (PCFprime)
    );

    pc pc1 (
        .clk    (clk),
        .rst    (rst),
        .en     (~StallF),
        .PCNext (PCFprime),
        .PC     (PCF)
    );

    adder32 add_pc_plus_4 (
        .A       (PCF),
        .B       (4),
        .Q       (PCPlus4F)
    );

    // Conexiones a la memoria imem externa
    assign PC = PCF;
    assign InstrF = Instr;

    pipe_reg_D prD1 (
        .clk      (clk),
        .rst      (rst),
        .en       (~StallD),
        .PCF      (PCF),
        .InstrF   (InstrF),
        .PCPlus4F (PCPlus4F),
        .PCD      (PCD),
        .InstrD   (InstrD),
        .PCPlus4D (PCPlus4D)
    );

    register_bank rb1 (
        .clk (clk),
        .rst (rst),
        .WE3 (RegWriteW),
        .A1  (InstrD[19:15]),
        .A2  (InstrD[24:20]),
        .A3  (RdW),
        .WD3 (ResultW),
        .RD1 (RD1D),
        .RD2 (RD2D)
    );

    assign RdD = InstrD[11:7];

    Extend ext1 (
        .src (ImmSrc),
        .A   (InstrD),
        .Q   (ImmExtD)
    );

    pipe_reg_E prE1 (
        .clk      (clk),
        .rst      (rst | FlushE),
        .RD1D     (RD1D),
        .RD2D     (RD2D),
        .PCD      (PCD),
        .Rs1D     (InstrD[19:15]),
        .Rs2D     (InstrD[24:20]),
        .RdD      (RdD),
        .ImmExtD  (ImmExtD),
        .PCPlus4D (PCPlus4D),
        .RD1E     (RD1E),
        .RD2E     (RD2E),
        .PCE      (PCE),
        .Rs1E     (Rs1E),
        .Rs2E     (Rs2E),
        .RdE      (RdE),
        .ImmExtE  (ImmExtE),
        .PCPlus4E (PCPlus4E)
    );

    mux32 mux_SrcB (
        .sel  (ALUSrc),
        .A    (RD2E),
        .B    (ImmExtE),
        .Q    (SrcBE)
    );

    adder32 add_pc_target (
        .A       (PCE),
        .B       (ImmExtE),
        .Q       (PCTargetE)
    );

    alu alu1 (
        .ALUControl (ALUControl),
        .A          (SrcAE),
        .B          (SrcBE),
        .Result     (ALUResultE),
        .oVerflow   (),
        .Carry      (),
        .Negative   (),
        .Zero       (zero)
    );

    mux32_4 mux_hazards_A (
        .sel  (ForwardAE),
        .A    (RD1E),
        .B    (ResultW),
        .C    (ALUResultM),
        .D    (),
        .Q    (SrcAE)
    );

    mux32_4 mux_hazards_B (
        .sel  (ForwardBE),
        .A    (RD2E),
        .B    (ResultW),
        .C    (ALUResultM),
        .D    (),
        .Q    (WriteDataE)
    );

    hazard_unit hu1 (
        .Rs1E         (Rs1E),
        .Rs2E         (Rs2E),
        .RdM          (RdM),
        .RdW          (RdW),
        .RegWriteM    (RegWriteM),
        .RegWriteW    (RegWriteW),
        .ForwardAE    (ForwardAE),
        .ForwardBE    (ForwardBE),
        .RdE          (RdE),
        .Rs1D         (Instr[19:15]),
        .Rs2D         (Instr[24:20]),
        .StallF       (StallF),
        .StallD       (StallD),
        .FlushE       (FlushE),
        .ResultSrcE_0 (ResultSrcE_0)
    );

    pipe_reg_M prM1 (
        .clk         (clk),
        .rst         (rst),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .RdE         (RdE),
        .PCPlus4E    (PCPlus4E),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),
        .PCPlus4M    (PCPlus4M)
    );

    assign ALUResult = ALUResultM;
    assign WriteData = WriteDataM;
    assign ReadDataM = ReadData;

    pipe_reg_W prW1 (
        .clk        (clk),
        .rst        (rst),
        .ALUResultM (ALUResultM),
        .ReadDataM  (ReadDataM),
        .RdM        (RdM),
        .PCPlus4M   (PCPlus4M),
        .ALUResultW (ALUResultW),
        .ReadDataW  (ReadDataW),
        .RdW        (RdW),
        .PCPlus4W   (PCPlus4W)
    );

    mux32_4 mux_result (
        .sel  (ResultSrc),
        .A    (ALUResultW),
        .B    (ReadDataW),
        .C    (PCPlus4W),
        .D    (),
        .Q    (ResultW) 
    );

endmodule : datapath


module control (
    input              clk,
    input              rst,
    input        [6:0] op,
    input        [2:0] funct3,
    input              funct7_bit5,
    input              ZeroE,
    output logic       PCSrc,
    output logic [1:0] ResultSrcE,
    output logic [1:0] ResultSrcW,
    output logic       MemWrite,
    output logic [2:0] ALUControl,
    output logic       ALUSrc,
    output logic [1:0] ImmSrc,
    output logic       RegWriteM,
    output logic       RegWriteW
);

    logic       JumpD;
    logic       BranchD;
    logic [1:0] ResultSrcD;
    logic       MemWriteD;
    logic [2:0] ALUControlD;
    logic       ALUSrcD;
    logic [1:0] ImmSrcD;
    logic       RegWriteD;

    logic       JumpE;
    logic       BranchE;
    logic       MemWriteE;
    logic [2:0] ALUControlE;
    logic       ALUSrcE;
    logic       RegWriteE;

    logic [1:0] ResultSrcM;
    logic       MemWriteM;

    assign ImmSrc = ImmSrcD;

    // Main Decoder
    logic [1:0] ALUOp;

    always_comb begin

        case (op[6:0])
            3: // lw
            begin
                ALUOp      = 2'b00;
                BranchD    = 1'b0;
                ResultSrcD = 2'b01;
                MemWriteD  = 1'b0;
                ALUSrcD    = 1'b1;
                ImmSrcD    = 2'b00;
                RegWriteD  = 1'b1;
                JumpD      = 1'b0;
            end
            35: // sw
            begin
                ALUOp      = 2'b00;
                BranchD    = 1'b0;
                ResultSrcD = 2'b00;
                MemWriteD  = 1'b1;
                ALUSrcD    = 1'b1;
                ImmSrcD    = 2'b01;
                RegWriteD  = 1'b0;
                JumpD      = 1'b0;
            end
            51: // R-type
            begin
                ALUOp      = 2'b10;
                BranchD    = 1'b0;
                ResultSrcD = 2'b00;
                MemWriteD  = 1'b0;
                ALUSrcD    = 1'b0;
                ImmSrcD    = 2'b00;
                RegWriteD  = 1'b1;
                JumpD      = 1'b0;
            end
            99: // beq
            begin
                ALUOp      = 2'b01;
                BranchD    = 1'b1;
                ResultSrcD = 2'b00;
                MemWriteD  = 1'b0;
                ALUSrcD    = 1'b0;
                ImmSrcD    = 2'b10;
                RegWriteD  = 1'b0;
                JumpD      = 1'b0;
            end
            19: // I-type
            begin
                ALUOp      = 2'b10;
                BranchD    = 1'b0;
                ResultSrcD = 2'b00;
                MemWriteD  = 1'b0;
                ALUSrcD    = 1'b1;
                ImmSrcD    = 2'b00;
                RegWriteD  = 1'b1;
                JumpD      = 1'b0;
            end
            111: // jal
            begin
                ALUOp      = 2'b00;
                BranchD    = 1'b0;
                ResultSrcD = 2'b10;
                MemWriteD  = 1'b0;
                ALUSrcD    = 1'b0;
                ImmSrcD    = 2'b11;
                RegWriteD  = 1'b1;
                JumpD      = 1'b1;
            end
            default: // not implemented
            begin
                ALUOp      = 2'b00;
                BranchD    = 1'b0;
                ResultSrcD = 1'b0;
                MemWriteD  = 1'b0;
                ALUSrcD    = 1'b0;
                ImmSrcD    = 2'b00;
                RegWriteD  = 1'b0;
                JumpD      = 1'b0;
            end
        endcase

    end

    assign PCSrcE = (BranchE && ZeroE) || JumpE;
    assign PCSrc  = PCSrcE;

    // ALU Decoder
    always_comb begin

        casex ({ALUOp,funct3,op[5],funct7_bit5})
            7'b00xxxxx: ALUControlD = 3'b000; // lw, sw
            7'b01xxxxx: ALUControlD = 3'b001; // beq
            7'b1000000: ALUControlD = 3'b000; // add
            7'b1000001: ALUControlD = 3'b000; // add
            7'b1000010: ALUControlD = 3'b000; // add
            7'b1000011: ALUControlD = 3'b001; // sub
            7'b10010xx: ALUControlD = 3'b101; // slt
            7'b10110xx: ALUControlD = 3'b011; // or
            7'b10111xx: ALUControlD = 3'b010; // and
            default:    ALUControlD = 3'b000;
        endcase

    end

    control_reg_D crD1 (
        .clk         (clk),
        .rst         (rst),
        .RegWriteD   (RegWriteD),
        .ResultSrcD  (ResultSrcD),
        .MemWriteD   (MemWriteD),
        .JumpD       (JumpD),
        .BranchD     (BranchD),
        .ALUControlD (ALUControlD),
        .ALUSrcD     (ALUSrcD),
        .RegWriteE   (RegWriteE),
        .ResultSrcE  (ResultSrcE),
        .MemWriteE   (MemWriteE),
        .JumpE       (JumpE),
        .BranchE     (BranchE),
        .ALUControlE (ALUControlE),
        .ALUSrcE     (ALUSrcE)
    );

    assign ALUSrc = ALUSrcE;
    assign ALUControl = ALUControlE;

    control_reg_E crE1 (
        .clk        (clk),
        .rst        (rst),
        .RegWriteE  (RegWriteE),
        .ResultSrcE (ResultSrcE),
        .MemWriteE  (MemWriteE),
        .RegWriteM  (RegWriteM),
        .ResultSrcM (ResultSrcM),
        .MemWriteM  (MemWriteM)
    );

    assign MemWrite = MemWriteM;

    control_reg_M crM1 (
        .clk        (clk),
        .rst        (rst),
        .RegWriteM  (RegWriteM),
        .ResultSrcM (ResultSrcM),
        .RegWriteW  (RegWriteW),
        .ResultSrcW (ResultSrcW)
    );

endmodule : control


// Program Counter
module pc ( 
    input               clk,
    input               rst,
    input               en,
    input        [31:0] PCNext,
    output logic [31:0] PC
);

    always_ff @ (posedge clk) begin
        if (rst) PC <= 32'h00400000; // text segment
        else if (en) PC <= PCNext;
        else PC <= PC;
    end

endmodule : pc


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
    always_ff @(negedge clk) begin
        if (rst) for (i = 0; i<32; i++) mem[i] <= 0;
        else if (WE3) mem[A3] <= WD3;
    end

    // read logic (combinational)
    assign RD1 = (A1 == 0) ? 32'b0 : mem[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : mem[A2];
    
endmodule : register_bank


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
            //default: Q = 32'hDEADBEEF; // error
        endcase

    end

endmodule : Extend


module reg_n #(parameter bits = 32) ( 
    input                   clk,
    input                   rst,
    input                   en,
    input        [bits-1:0] din,
    output logic [bits-1:0] dout
);

    always_ff @ (posedge clk) begin
        if      (rst) dout <= 0;
        else if (en)  dout <= din;
        else          dout <= dout;
    end

endmodule : reg_n


module mux32 (
    input               sel,
    input        [31:0] A,
    input        [31:0] B,
    output logic [31:0] Q 
);

    assign Q = sel ? B : A;

endmodule : mux32


module mux32_4 (
    input         [1:0] sel,
    input        [31:0] A,
    input        [31:0] B,
    input        [31:0] C,
    input        [31:0] D,
    output logic [31:0] Q 
);

    always_comb begin
        case (sel)
            2'b00: Q = A;
            2'b01: Q = B;
            2'b10: Q = C;
            2'b11: Q = D;
        endcase
    end

endmodule : mux32_4


module adder32 (
    input        [31:0] A,
    input        [31:0] B,
    output logic [31:0] Q
);

    assign Q = A + B;

endmodule : adder32


module pipe_reg_D (
    input clk,
    input rst,
    input en,
    input [31:0] PCF,
    input [31:0] InstrF,
    input [31:0] PCPlus4F,
    output logic [31:0] PCD,
    output logic [31:0] InstrD,
    output logic [31:0] PCPlus4D
);

    reg_n #(.bits(32)) reg_PC (
        .clk  (clk),
        .rst  (rst),
        .en   (en),
        .din  (PCF),
        .dout (PCD)
    );

    reg_n #(.bits(32)) reg_Instr (
        .clk  (clk),
        .rst  (rst),
        .en   (en),
        .din  (InstrF),
        .dout (InstrD)
    );

    reg_n #(.bits(32)) reg_PCPlus4 (
        .clk  (clk),
        .rst  (rst),
        .en   (en),
        .din  (PCPlus4F),
        .dout (PCPlus4D)
    );

endmodule : pipe_reg_D


module pipe_reg_E (
    input        clk,
    input        rst,
    input [31:0] RD1D,
    input [31:0] RD2D,
    input [31:0] PCD,
    input  [4:0] Rs1D,
    input  [4:0] Rs2D,
    input  [4:0] RdD,
    input [31:0] ImmExtD,
    input [31:0] PCPlus4D,
    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] PCE,
    output logic  [4:0] Rs1E,
    output logic  [4:0] Rs2E,
    output logic  [4:0] RdE,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCPlus4E
);

    reg_n #(.bits(32)) reg_RD1 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RD1D),
        .dout (RD1E)
    );

    reg_n #(.bits(32)) reg_RD2 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RD2D),
        .dout (RD2E)
    );

    reg_n #(.bits(32)) reg_PC (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCD),
        .dout (PCE)
    );

    reg_n #(.bits(5)) reg_Rs1 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (Rs1D),
        .dout (Rs1E)
    );

    reg_n #(.bits(5)) reg_Rs2 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (Rs2D),
        .dout (Rs2E)
    );

    reg_n #(.bits(5)) reg_Rd (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RdD),
        .dout (RdE)
    );

    reg_n #(.bits(32)) reg_ImmExt (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ImmExtD),
        .dout (ImmExtE)
    );

    reg_n #(.bits(32)) reg_PCPlus4 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCPlus4D),
        .dout (PCPlus4E)
    );

endmodule : pipe_reg_E


module pipe_reg_M (
    input clk,
    input rst,
    input [31:0] ALUResultE,
    input [31:0] WriteDataE,
    input [4:0] RdE,
    input [31:0] PCPlus4E,
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic  [4:0] RdM,
    output [31:0] PCPlus4M
);

    reg_n #(.bits(32)) reg_ALUResult (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ALUResultE),
        .dout (ALUResultM)
    );

    reg_n #(.bits(32)) reg_WriteData (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (WriteDataE),
        .dout (WriteDataM)
    );

    reg_n #(.bits(5)) reg_Rd (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RdE),
        .dout (RdM)
    );

    reg_n #(.bits(32)) reg_PCPlus4 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCPlus4E),
        .dout (PCPlus4M)
    );

endmodule : pipe_reg_M

module pipe_reg_W (
    input clk,
    input rst,
    input [31:0] ALUResultM,
    input [31:0] ReadDataM,
    input  [4:0] RdM,
    input [31:0] PCPlus4M,
    output logic [31:0] ALUResultW,
    output logic [31:0] ReadDataW,
    output logic  [4:0] RdW,
    output logic [31:0] PCPlus4W
);

    reg_n #(.bits(32)) reg_ALUResult (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ALUResultM),
        .dout (ALUResultW)
    );

    reg_n #(.bits(32)) reg_ReadData (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ReadDataM),
        .dout (ReadDataW)
    );

    reg_n #(.bits(5)) reg_Rd (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RdM),
        .dout (RdW)
    );

    reg_n #(.bits(32)) reg_PCPlus4 (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCPlus4M),
        .dout (PCPlus4W)
    );

endmodule : pipe_reg_W


module control_reg_D (
    input clk,
    input rst,
    input RegWriteD,
    input [1:0] ResultSrcD,
    input MemWriteD,
    input JumpD,
    input BranchD,
    input [2:0] ALUControlD,
    input ALUSrcD,
    output logic RegWriteE,
    output logic [1:0] ResultSrcE,
    output logic MemWriteE,
    output logic JumpE,
    output logic BranchE,
    output logic [2:0] ALUControlE,
    output logic ALUSrcE
);

    reg_n #(.bits(1)) reg_RegWrite (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RegWriteD),
        .dout (RegWriteE)
    );

    reg_n #(.bits(2)) reg_ResultSrc (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ResultSrcD),
        .dout (ResultSrcE)
    );

    reg_n #(.bits(1)) reg_MemWrite (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (MemWriteD),
        .dout (MemWriteE)
    );

    reg_n #(.bits(1)) reg_Jump (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (JumpD),
        .dout (JumpE)
    );

    reg_n #(.bits(1)) reg_Branch (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (BranchD),
        .dout (BranchE)
    );

    reg_n #(.bits(3)) reg_ALUControl (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ALUControlD),
        .dout (ALUControlE)
    );

    reg_n #(.bits(1)) reg_ALUSrc (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ALUSrcD),
        .dout (ALUSrcE)
    );

endmodule : control_reg_D


module control_reg_E (
    input clk,
    input rst,
    input RegWriteE,
    input [1:0] ResultSrcE,
    input MemWriteE,
    output logic RegWriteM,
    output logic [1:0] ResultSrcM,
    output logic MemWriteM
);

    reg_n #(.bits(1)) reg_RegWrite (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RegWriteE),
        .dout (RegWriteM)
    );

    reg_n #(.bits(2)) reg_ResultSrc (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ResultSrcE),
        .dout (ResultSrcM)
    );

    reg_n #(.bits(1)) reg_MemWrite (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (MemWriteE),
        .dout (MemWriteM)
    );

endmodule : control_reg_E


module control_reg_M (
    input clk,
    input rst,
    input RegWriteM,
    input [1:0] ResultSrcM,
    output logic RegWriteW,
    output logic [1:0] ResultSrcW
);

    reg_n #(.bits(1)) reg_RegWrite (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RegWriteM),
        .dout (RegWriteW)
    );

    reg_n #(.bits(2)) reg_ResultSrc (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ResultSrcM),
        .dout (ResultSrcW)
    );

endmodule : control_reg_M


module hazard_unit (
    // forwarding
    input        [4:0] Rs1E,
    input        [4:0] Rs2E,
    input        [4:0] RdM,
    input        [4:0] RdW,
    input              RegWriteM,
    input              RegWriteW,
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE,
    // stalling
    input        [4:0] Rs1D,
    input        [4:0] Rs2D,
    input        [4:0] RdE,
    input              ResultSrcE_0,
    output logic       StallF,
    output logic       StallD,
    output logic       FlushE
);

    // forwarding
    always_comb begin
        if ((Rs1E == RdM) & RegWriteM & (Rs1E != 0))      ForwardAE = 2'b10;
        else if ((Rs1E == RdW) & RegWriteW & (Rs1E != 0)) ForwardAE = 2'b01;
        else                                              ForwardAE = 2'b00;
    end

    always_comb begin
        if ((Rs2E == RdM) & RegWriteM & (Rs2E != 0))      ForwardBE = 2'b10;
        else if ((Rs2E == RdW) & RegWriteW & (Rs2E != 0)) ForwardBE = 2'b01;
        else                                              ForwardBE = 2'b00;
    end

    // stalling
    logic  lwStall;
    assign lwStall = ResultSrcE_0 & ((Rs1D == RdE) | (Rs2D == RdE));
    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushE = lwStall;

endmodule : hazard_unit
