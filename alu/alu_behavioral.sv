// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Author:      Juan José Montero Rodríguez
// Date:        11.09.2024
// Description: RISC-V ALU (Behavioral)
// Note:        Each operation needs to be replaced with proper hardware

module ALU (
    input        [2:0]  Ctrl,
    input        [31:0] SrcA,
    input        [31:0] SrcB,
    output logic [31:0] Result,
    output logic        zero
);

    always_comb begin

        case (Ctrl)
            3'b000:  Result = SrcA + SrcB;              // add
            3'b001:  Result = SrcA - SrcB;              // subtract
            3'b010:  Result = SrcA && SrcB;             // and
            3'b011:  Result = SrcA || SrcB;             // or
            3'b101:  Result = (SrcA < SrcB) ? 1 : 0;    // slt (set if less than)
            default: Result = 32'hDEADBEEF;             // error
        endcase

    end

    assign zero = (Result == 0) ? 1 : 0;

endmodule
