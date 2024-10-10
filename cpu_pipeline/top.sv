module top (
    input clk,
    input rst
);

    logic [31:0] PC;
    logic [31:0] Instr;
    logic [31:0] DataAdr;
    logic [31:0] WriteData;
    logic [31:0] ReadData;
    logic        MemWrite;

    cpu cpu1 (
        .clk         (clk),
        .rst         (rst),
        .PC          (PC),
        .Instr       (Instr),
        .ALUResult   (DataAdr),
        .WriteData   (WriteData),
        .ReadData    (ReadData),
        .MemWrite    (MemWrite)
    );

    dmem dmem1(
        .clk (clk),
        .rst (rst),
        .WE  (MemWrite),
        .RE  (1'b1),
        .A   (DataAdr),
        .WD  (WriteData),
        .RD  (ReadData)
    );

    imem imem1(
        .A   (PC),
        .RD  (Instr)
    );

endmodule
