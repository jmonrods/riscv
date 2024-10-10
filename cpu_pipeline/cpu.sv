
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

endmodule



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

endmodule


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

endmodule
