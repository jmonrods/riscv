// tester: drives stimulus
class tester;
    
    virtual cpu_bfm bfm;

    function new (virtual cpu_bfm b);
        bfm = b;
    endfunction

    task execute();

        Instruction in;

        bfm.reset_cpu();

        repeat (10) begin
            @(posedge bfm.clk);
            in = new();
            `SV_RAND_CHECK(in.randomize());
            bfm.Instr = in.instr;
            in.print_instr();
        end

        $finish();
        
    endtask : execute

endclass

