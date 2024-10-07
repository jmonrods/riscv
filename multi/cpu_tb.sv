// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       26.08.2024
// Descripción: RISC-V CPU Testbench (Multicycle)

`timescale 1ns/1ps

module cpu_tb ();

    reg clk;
    reg rst;
    wire [31:0] read_data;

    cpu cpu1 (
        .clk(clk),
        .rst(rst),
        .Result(read_data)
    );

    initial begin

        rst <= 1;
        #10 rst <= 0;
        $display(read_data);

        repeat (100) #10 $display($signed(read_data));

        #100 $finish();

    end

    initial begin

        clk <= 0;
        forever #5 clk <= !clk;

    end

endmodule
