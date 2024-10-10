// Data Memory
// RAM (aligned by 4)
module dmem (
    input clk,
    input rst,
    input WE,
    input RE,
    input [31:0] A,
    input [31:0] WD,
    output logic [31:0] RD
);

    // associative array: dynamic memory
    logic [31:0] mem [logic [31:0]];

    // write logic
    always_ff @(posedge clk) begin
        if (rst) mem.delete();
	else if (WE) mem[A] = WD;
    end

    // read logic
    always_ff @(posedge clk) begin
        if (RE & !rst) RD = mem[A];
        else           RD = 32'hDEADBEEF;
    end

endmodule