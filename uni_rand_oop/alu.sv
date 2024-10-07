// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       11.09.2024
// Descripción: RISC-V ALU

`timescale 1ns/1ps

module alu (
    input        [2:0]  ALUControl,
    input        [31:0] A,
    input        [31:0] B,
    output logic [31:0] Result,
    output logic        oVerflow,
    output logic        Carry,
    output logic        Negative,
    output logic        Zero
);

    wire [31:0] B_a2;
    wire [31:0] Sum;
    wire [31:0] S_slt;

    assign B_a2 = (ALUControl[0]) ? ~B : B;

    adder_ripple_carry add1 (
        .A      (A),
        .B      (B_a2),
        .Cin    (ALUControl[0]),
        .Cout   (Cout),
        .S      (Sum)
    );

    mux_out mux1 (
        .sel    (ALUControl),
        .S_add  (Sum),
        .S_sub  (Sum),
        .S_and  (A & B),
        .S_or   (A | B),
        .S_slt  (S_slt),
        .out    (Result)
    );

    ZeroExt ext1 (
        .oVerflow  (oVerflow),
        .Sum_msb   (Sum[31]),
        .out       (S_slt)
    );

    // flags
    assign Zero = (Result == 32'b0) ? 1'b1 : 1'b0;
    assign oVerflow = ~(A[31] ^ B[31] ^ ALUControl[0]) & (A[31] ^ Sum[31]) & ~ALUControl[1];
    assign Carry = ~ALUControl[1] & Cout;
    assign Negative = Sum[31];

endmodule


module full_adder (
    input        A,
    input        B,
    input        Cin,
    output logic S,
    output logic Cout
);

    assign S = (A ^ B) ^ Cin;
    assign Cout = ((A ^ B) & Cin) + (A & B);

endmodule


module adder_ripple_carry (
    input        [31:0] A,
    input        [31:0] B,
    input               Cin,
    output logic        Cout,
    output logic [31:0] S
);

    wire [31:0] cin_n;

    genvar i;
    generate
        for (i=0 ; i<32 ; i++) begin
            if (i==0) begin
                full_adder f_add_n (
                .A(A[i]),
                .B(B[i]),
                .Cin(Cin),
                .Cout(cin_n[i]),
                .S(S[i])
            );
            end else if (i<31) begin
                full_adder f_add_n (
                .A(A[i]),
                .B(B[i]),
                .Cin(cin_n[i-1]),
                .Cout(cin_n[i]),
                .S(S[i])
            );
            end else begin
                full_adder f_add_n (
                .A(A[i]),
                .B(B[i]),
                .Cin(cin_n[i-1]),
                .Cout(Cout),
                .S(S[i])
            );
            end
        end
    endgenerate

endmodule


module mux_out (
    input        [2:0]  sel,
    input        [31:0] S_add,
    input        [31:0] S_sub,
    input        [31:0] S_and,
    input        [31:0] S_or,
    input        [31:0] S_slt,
    output logic [31:0] out
);

    always_comb begin
    
        case (sel)
            3'b000:  out = S_add;
            3'b001:  out = S_sub;
            3'b010:  out = S_and;
            3'b011:  out = S_or;
            3'b101:  out = S_slt;
            default: out = 32'hDEADBEEF;
        endcase
    
    end

endmodule


module ZeroExt (
    input         oVerflow,
    input         Sum_msb,
    output [31:0] out
    );

    assign out = (oVerflow ^ Sum_msb) ? {32{1'b1}} : {32{1'b0}};

endmodule
