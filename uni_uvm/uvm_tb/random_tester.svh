// random_tester: drives stimulus
class random_tester extends uvm_component;
    `uvm_component_utils(random_tester);
    
    virtual cpu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*", "bfm", bfm))
            $fatal("Failed to get BFM");
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        bfm.reset_cpu();
        repeat (400000) bfm.send_instruction();
        $finish();
        
    endtask : run_phase

endclass

