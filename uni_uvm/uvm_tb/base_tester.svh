virtual class base_tester extends uvm_component;
    `uvm_component_utils(base_tester);
    
    virtual cpu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*","bfm", bfm))
            $fatal("Failed to get BFM");
    endfunction : build_phase

    pure virtual function op_e get_op();

    pure virtual function data_s get_data();

    task run_phase(uvm_phase phase);
        op_e      operation;
        data_s    data;

        phase.raise_objection(this);

        bfm.reset_cpu();

        repeat (1000) begin : random_loop
            operation = get_op();
            data      = get_data();
            bfm.send_instruction(operation, data);
        end : random_loop
        
        phase.drop_objection(this);
        
    endtask : run_phase

endclass

