// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       16.10.2024
// Descripción: RISC-V Pipelined CPU from Harris & Harris

`timescale 1ns/1ps

module top (
    input clk,
    input rst,
    output logic [31:0] PC,
    output logic [31:0] Instr,
    output logic [31:0] Result
);

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
        .MemWrite    (MemWrite),
        .Result      (Result)
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
