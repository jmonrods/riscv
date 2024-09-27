`timescale 1ns/1ps

// bus functional model of the CPU
interface cpu_bfm;

    logic clk, rst;
    logic [31:0] Instr;
    logic [31:0] Result;

    initial begin
        clk = 0;
        forever begin
            #10;
            clk = ~clk;
        end
    end

    task reset_cpu();
        
        rst = 1;
        @(posedge clk);
        rst = 0;

    endtask : reset_cpu

endinterface
