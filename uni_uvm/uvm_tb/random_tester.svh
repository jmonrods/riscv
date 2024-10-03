// random_tester: drives stimulus
class random_tester;
    
    virtual cpu_bfm bfm;

    function new (virtual cpu_bfm b);
        bfm = b;
    endfunction

    task execute();

        bfm.reset_cpu();
        repeat (400000) bfm.send_instruction();
        $finish();
        
    endtask : execute

endclass

