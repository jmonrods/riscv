class add_tester extends random_tester;
    `uvm_component_utils(add_tester);
    
    function op_e get_op();
        op_e operation;
        operation = ADD;
        return operation;
    endfunction : get_op

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass

