// scoreboard: checks if the cpu is working
class scoreboard;

    virtual cpu_bfm bfm;

    function new (virtual cpu_bfm b);
        bfm = b;
    endfunction : new


    task execute();
        
        logic [31:0] predicted_result;

        forever begin : self_checker
            
            @(posedge bfm.clk) #1;
            
            case(bfm.in.operation)
                ADD:  predicted_result = bfm.in.rs1 + bfm.in.rs2;
                SUB:  predicted_result = bfm.in.rs1 - bfm.in.rs2;
                AND:  predicted_result = bfm.in.rs1 & bfm.in.rs2;
                OR:   predicted_result = bfm.in.rs1 | bfm.in.rs2;
                SLT:  predicted_result = (bfm.in.rs1 < bfm.in.rs2) ? 32'hFFFFFFFF : 32'h00000000;
                ADDI: predicted_result = bfm.in.rs1 + bfm.in.imm;
            endcase

            if (predicted_result !== bfm.result) $error("FAILED: rs1: %0h  rs2: %0h  imm: %0h  op: %s  result: %0h  expected: %0h", bfm.in.rs1, bfm.in.rs2, bfm.in.imm, bfm.in.operation.name(), bfm.result, predicted_result);
            else $display("PASSED: rs1: %0h  rs2: %0h  imm: %0h  op: %s  result: %0h  expected: %0h", bfm.in.rs1, bfm.in.rs2, bfm.in.imm, bfm.in.operation.name(), bfm.result, predicted_result);

        end : self_checker
    
    endtask

endclass


