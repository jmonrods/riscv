// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       12.09.2024
// Descripción: RISC-V ALU Testbench

`timescale 1ns/1ps

module alu_tb ();

    logic [2:0]  ALUControl;
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] Result;
    logic        V;
    logic        C;
    logic        N;
    logic        Z;

    alu alu1 (
        .ALUControl (ALUControl),
        .A          (A),
        .B          (B),
        .Result     (Result),
        .oVerflow   (V),
        .Carry      (C),
        .Negative   (N),
        .Zero       (Z)
    );

    initial begin

        // Test values
        A = 32'h01233567;
        B = 32'h76543210;
        $display("%t ps: A = 32'h%h",$time,A);
        $display("%t ps: B = 32'h%h",$time,B);

        // Add
        ALUControl = 3'b000;
        #50 $display("%t ps: A + B   = 32'h%h, VCNZ: %b%b%b%b",$time,Result,V,C,N,Z);
        
        // Sub
        #50 ALUControl = 3'b001;
        #50 $display("%t ps: A - B   = 32'h%h, VCNZ: %b%b%b%b",$time,Result,V,C,N,Z);

        // And
        #50 ALUControl = 3'b010;
        #50 $display("%t ps: A & B   = 32'h%h, VCNZ: %b%b%b%b",$time,Result,V,C,N,Z);

        // Or
        #50 ALUControl = 3'b011;
        #50 $display("%t ps: A | B   = 32'h%h, VCNZ: %b%b%b%b",$time,Result,V,C,N,Z);

        // SLT
        #50 ALUControl = 3'b101;
        #50 $display("%t ps: A slt B = 32'h%h, VCNZ: %b%b%b%b",$time,Result,V,C,N,Z);
        
        // End
        #100;
        $finish();

    end

endmodule
