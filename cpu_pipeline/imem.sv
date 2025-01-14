// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       16.10.2024
// Descripción: RISC-V Instruction Memory

`timescale 1ns/1ps

module imem (
    input        [31:0] A,
    output logic [31:0] RD
);

    always_comb begin
        case (A) // instructions in machine language
            32'h00400000: RD = 32'h00100413; // addi x8, x0, 1
            32'h00400004: RD = 32'h00200493; // addi x9, x0, 2
            32'h00400008: RD = 32'h00300513; // addi x10, x0, 3
            32'h0040000C: RD = 32'h00400593; // addi x11, x0, 4
            32'h00400010: RD = 32'h00500613; // addi x12, x0, 5
            32'h00400014: RD = 32'h00600693; // addi x13, x0, 6
            32'h00400018: RD = 32'h00700713; // addi x14, x0, 7
            32'h0040001C: RD = 32'h00800793; // addi x15, x0, 8
            32'h00400020: RD = 32'h00900813; // addi x16, x0, 9
            32'h00400024: RD = 32'h00a00893; // addi x17, x0, 10
            32'h00400028: RD = 32'h00940933; // add x18, x8, x9
            32'h0040002C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400030: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400034: RD = 32'h00940933; // add x18, x8, x9
            32'h00400038: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040003C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400040: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400044: RD = 32'h00940933; // add x18, x8, x9
            32'h00400048: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040004C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400050: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400054: RD = 32'h00940933; // add x18, x8, x9
            32'h00400058: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040005C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400060: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400064: RD = 32'h00940933; // add x18, x8, x9
            32'h00400068: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040006C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400070: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400074: RD = 32'h00940933; // add x18, x8, x9
            32'h00400078: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040007C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400080: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400084: RD = 32'h00940933; // add x18, x8, x9
            32'h00400088: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040008C: RD = 32'h00940933; // add x18, x8, x9
            32'h00400090: RD = 32'h409409B3; // sub x19, x8, x9
            32'h00400094: RD = 32'h00940933; // add x18, x8, x9
            32'h00400098: RD = 32'h409409B3; // sub x19, x8, x9
            32'h0040009C: RD = 32'h00940933; // add x18, x8, x9
            32'h004000A0: RD = 32'h409409B3; // sub x19, x8, x9
            default:      RD = 32'hDEADBEEF; // error: pc out of bounds
        endcase
    end

endmodule