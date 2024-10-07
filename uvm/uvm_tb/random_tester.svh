class random_tester extends base_tester;
    `uvm_component_utils(random_tester);

    function data_s get_data();
        data_s data;
        data.rs1 = $random;
        data.rs2 = $random;
        data.rd  = $random;
        data.imm = $random;
        return data;
    endfunction : get_data

    function op_e get_op();
        op_e operation;
        logic [2:0] op;
        op = $random;
        case (op)
            3'b000:  operation = ADD;
            3'b001:  operation = SUB;
            3'b010:  operation = AND;
            3'b011:  operation = OR;
            3'b100:  operation = ADDI;
            3'b101:  operation = SLT;
            default: operation = ADD;
        endcase
        return operation;
    endfunction : get_op

    function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass

