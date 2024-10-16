// Instituto Tecnológico de Costa Rica
// EL-3310 Diseño de sistemas digitales
// Autor:       Juan José Montero Rodríguez
// Fecha:       16.10.2024
// Descripción: RISC-V Pipelined CPU Testbench

`timescale 1ns/1ps

module top_tb();

    logic clk;
    logic rst;

    top top1 (clk, rst);

    initial begin
        rst = 1;
        #10;
        rst = 0;

        #200 $finish();
    end

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end


endmodule
