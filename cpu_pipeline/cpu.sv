// riscv pipeline
module cpu (
    input        clk,
    input        rst,
    input [31:0] Instr,
    input [31:0] ReadData,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    output logic MemWrite
);

    logic       PCSrc;
    logic [1:0] ResultSrc;
    logic [2:0] ALUControl;
    logic       ALUSrc;
    logic       MemWrite;
    logic [1:0] ImmSrc;
    logic       RegWrite;
    logic       zero;

    datapath data1 (
        .clk         (clk),
        .rst         (rst),
        .Instr       (Instr),
        .ReadData    (ReadData),
        .PCSrc       (PCSrc),
        .ResultSrc   (ResultSrc),
        .ALUControl  (ALUControl),
        .ALUSrc      (ALUSrc),
        .ImmSrc      (ImmSrc),
        .RegWrite    (RegWrite),
        .PC          (PC),
        .ALUResult   (ALUResult),
        .WriteData   (WriteData),
        .zero        (zero)
    );

    control ctrl1 (
        .op          (Instr[6:0]),
        .funct3      (Instr[14:12]),
        .funct7_bit5 (Instr[30]),
        .Zero        (zero),
        .PCSrc       (PCSrc),
        .ResultSrc   (ResultSrc),
        .MemWrite    (MemWrite),
        .ALUControl  (ALUControl),
        .ALUSrc      (ALUSrc),
        .ImmSrc      (ImmSrc),
        .RegWrite    (RegWrite)
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
    input               RegWrite,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    output logic        zero
);

    mux32 mux_pc_src (
        .sel (PCSrc),
        .A   (PCPlus4F),
        .B   (PCTargetE),
        .Q   (PCFprime)
    );

    pc pc1 (
        .clk    (clk),
        .rst    (rst),
        .en     (1'b1),
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
        .WE3 (RegWrite),
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
        .rst      (rst),
        .RD1D     (RD1D),
        .RD2D     (RD2D),
        .PCD      (PCD),
        .RdD      (RdD),
        .ImmExtD  (ImmExtD),
        .PCPlus4D (PCPlus4D),
        .RD1E     (RD1E),
        .RD2E     (RD2E),
        .PCE      (PCE),
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
        .Zero       (Zero)
    );

    assign WriteDataE = RD2E;

    pipe_reg_M prM1 (
        .clk         (clk),
        .rst         (rst),
        .ALUResultE  (ALUResultE),
        .WriteDataE  (WriteDataE),
        .RdE         (RdE),
        .PCTargetE   (PCTargetE),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .RdM         (RdM),
        .PCTargetM   (PCTargetM)
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

    module mux32_4 (
        .sel  (ResultSrc),
        .A    (ALUResultW),
        .B    (ReadDataW),
        .C    (PCPlus4W),
        .D    (0),
        .Q    (ResultW) 
    );

endmodule : datapath


module control (
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
                ResultSrc = 1'b0;
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

        casex ({ALUOp,funct3,op[5],funct7_bit5})
            7'b00xxxxx: ALUControl = 3'b000; // lw, sw
            7'b01xxxxx: ALUControl = 3'b001; // beq
            7'b1000000: ALUControl = 3'b000; // add
            7'b1000001: ALUControl = 3'b000; // add
            7'b1000010: ALUControl = 3'b000; // add
            7'b1000011: ALUControl = 3'b001; // sub
            7'b10010xx: ALUControl = 3'b101; // slt
            7'b10110xx: ALUControl = 3'b011; // or
            7'b10111xx: ALUControl = 3'b010; // and
            default:    ALUControl = 3'b000;
        endcase

    end

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
    input [31:0] PCF,
    input [31:0] InstrF,
    input [31:0] PCPlus4F,
    output logic [31:0] PCD,
    output logic [31:0] InstrD,
    output logic [31:0] PCPlus4D
);

    reg_n reg_PC #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCF),
        .dout (PCD)
    );

    reg_n reg_Instr #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (InstrF),
        .dout (InstrD)
    );

    reg_n reg_PCPlus4 #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
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
    input [31:0] RdD,
    input [31:0] ImmExtD,
    input [31:0] PCPlus4D,
    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] PCE,
    output logic [31:0] RdE,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCPlus4E
);

    reg_n reg_RD1 #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RD1D),
        .dout (RD1E)
    );

    reg_n reg_RD2 #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RD2D),
        .dout (RD2E)
    );

    reg_n reg_PC #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCD),
        .dout (PCE)
    );

    reg_n reg_Rd #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RdD),
        .dout (RdE)
    );

    reg_n reg_ImmExt #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ImmExtD),
        .dout (ImmExtE)
    );

    reg_n reg_PCPlus4 #(.bits(32)) (
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
    input [31:0] RdE,
    input [31:0] PCTargetE,
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic [31:0] RdM,
    output logic [31:0] PCTargetM
);

    reg_n reg_ALUResult #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ALUResultE),
        .dout (ALUResultM)
    );

    reg_n reg_WriteData #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (WriteDataE),
        .dout (WriteDataM)
    );

    reg_n reg_Rd #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RdE),
        .dout (RdM)
    );

    reg_n reg_PCTarget #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCTargetE),
        .dout (PCTargetM)
    );

endmodule : pipe_reg_M

module pipe_reg_W (
    input clk,
    input rst,
    input [31:0] ALUResultM,
    input [31:0] ReadDataM,
    input [31:0] RdM,
    input [31:0] PCPlus4M,
    output logic [31:0] ALUResultW,
    output logic [31:0] ReadDataW,
    output logic [31:0] RdW,
    output logic [31:0] PCPlus4W
);

    reg_n reg_ALUResult #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ALUResultM),
        .dout (ALUResultW)
    );

    reg_n reg_ReadData #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (ReadDataM),
        .dout (ReadDataW)
    );

    reg_n reg_Rd #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (RdM),
        .dout (RdW)
    );

    reg_n reg_PCPlus4 #(.bits(32)) (
        .clk  (clk),
        .rst  (rst),
        .en   (1'b1),
        .din  (PCPlus4M),
        .dout (PCPlus4W)
    );

endmodule : pipe_reg_W
