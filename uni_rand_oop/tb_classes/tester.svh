// tester: drives stimulus
class tester;
    
    virtual cpu_bfm bfm;

    function new (virtual cpu_bfm b);
        bfm = b;
    endfunction

    task execute();

        bfm.reset_cpu();
        repeat (40) bfm.send_instruction();
        $finish();
        
    endtask : execute

endclass

