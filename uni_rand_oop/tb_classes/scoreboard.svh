// scoreboard: checks if the cpu is working
class scoreboard;

    virtual cpu_bfm bfm;

    function new (virtual cpu_bfm b);
        bfm = b;
    endfunction : new


    task execute();
        
        logic [31:0] predicted_result;
        logic [31:0] register_bank [32];

        int i;
        for (i=0; i<32; i++) register_bank[i] = 0;

        forever begin : self_checker
            
            @(posedge bfm.clk) #1;

            case(bfm.in.operation)
                ADD:  predicted_result = register_bank[bfm.in.rs1] + register_bank[bfm.in.rs2];
                SUB:  predicted_result = register_bank[bfm.in.rs1] - register_bank[bfm.in.rs2];
                AND:  predicted_result = register_bank[bfm.in.rs1] & register_bank[bfm.in.rs2];
                OR:   predicted_result = register_bank[bfm.in.rs1] | register_bank[bfm.in.rs2];
                SLT:  predicted_result = (register_bank[bfm.in.rs1] < register_bank[bfm.in.rs2]) ? 32'hFFFFFFFF : 32'h00000000;
                ADDI: predicted_result = register_bank[bfm.in.rs1] + {{20{bfm.in.imm[11]}},bfm.in.imm};
            endcase

            register_bank[bfm.in.rd] = (bfm.in.rd == 0) ? 32'h00000000 : predicted_result;

            if (predicted_result !== bfm.result) $error("FAILED: rs1: %0d  rs2: %0d  imm: %0d  op: %s  result: 0x%0h  expected: 0x%0h", bfm.in.rs1, bfm.in.rs2, bfm.in.imm, bfm.in.operation.name(), bfm.result, predicted_result);
            else $display("PASSED: rs1: %0d  rs2: %0d  imm: %0d  op: %s  result: 0x%0h  expected: 0x%0h", bfm.in.rs1, bfm.in.rs2, bfm.in.imm, bfm.in.operation.name(), bfm.result, predicted_result);

        end : self_checker
    
    endtask

endclass


