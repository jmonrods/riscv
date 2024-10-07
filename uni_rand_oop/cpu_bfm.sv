`timescale 1ns/1ps

// bus functional model of the CPU
interface cpu_bfm;

    import cpu_pkg::*;
    `include "cpu_macros.svh"

    logic clk, rst;
    logic [31:0] instr;
    logic [31:0] result;

    Instruction in;

    initial begin
        clk = 1;
        forever begin
            #5;
            clk = ~clk;
        end
    end

    task reset_cpu();
        
        rst = 1;
        @(posedge clk);
        rst = 0;

    endtask : reset_cpu

    task send_instruction();

        in = new();
        `SV_RAND_CHECK(in.randomize());
        //in.print_instr();

        instr = in.instr;
        
        @(posedge clk);

    endtask : send_instruction

endinterface
