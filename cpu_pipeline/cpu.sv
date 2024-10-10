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

    logic       PCSrcD;
    logic [1:0] ResultSrcD;
    logic [2:0] ALUControlD;
    logic       ALUSrcD;
    logic       MemWriteD;
    logic [1:0] ImmSrcD;
    logic       RegWriteD;
    logic       zero;

    datapath data1 (
        .clk         (clk),
        .rst         (rst),
        .Instr       (Instr),
        .ReadData    (ReadData),
        .PCSrc       (PCSrcD),
        .ResultSrc   (ResultSrcD),
        .ALUControl  (ALUControlD),
        .ALUSrc      (ALUSrcD),
        .ImmSrc      (ImmSrcD),
        .RegWrite    (RegWriteD),
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
        .PCSrc       (PCSrcD),
        .ResultSrc   (ResultSrcD),
        .MemWrite    (MemWriteD),
        .ALUControl  (ALUControlD),
        .ALUSrc      (ALUSrcD),
        .ImmSrc      (ImmSrcD),
        .RegWrite    (RegWriteD)
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
    
);

endmodule : pipe_reg_D


module pipe_reg_E (

);

endmodule : pipe_reg_E


module pipe_reg_M (

);


endmodule : pipe_reg_M

module pipe_reg_W (

);

endmodule : pipe_reg_W
