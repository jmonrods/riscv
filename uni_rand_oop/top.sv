
module top();

    import cpu_pkg::*;

    `include "cpu_macros.svh"    
    `include "coverage.svh"
    `include "tester.svh"
    `include "scoreboard.svh"
    `include "testbench.svh"

    cpu DUT (
        .rst(bfm.rst),
        .clk(bfm.clk),
        .Instr(bfm.Instr),
        .Result(bfm.Result)
    );

    cpu_bfm bfm ();

    testbench testbench_h;

    initial begin
        testbench_h = new(bfm);
        testbench_h.execute();
    end

endmodule : top
