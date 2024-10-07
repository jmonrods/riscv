// scoreboard: checks if the cpu is working
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard);

    virtual cpu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*", "bfm", bfm))
            $fatal("Failed to get BFM");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        
        logic [31:0] predicted_result;
        logic [31:0] register_bank [32];

        logic [4:0]  rs1;
        logic [4:0]  rs2;
        logic [4:0]  rd;
        logic [11:0] imm;
        logic [6:0]  opcode;
        logic [2:0]  funct3;
        logic [6:0]  funct7;

        op_e operation;

        int i;
        for (i=0; i<32; i++) register_bank[i] = 0;

        forever begin : self_checker
            
            @(posedge bfm.clk) #1;

            rd  = bfm.instr[11:7];
            rs1 = bfm.instr[19:15];
            rs2 = bfm.instr[24:20];
            imm = bfm.instr[31:20];
            opcode = bfm.instr[6:0];
            funct3 = bfm.instr[14:12];
            funct7 = bfm.instr[31:25];

            case (opcode)
                7'b0110011: // r-type 
                begin
                    case (funct3)
                        3'b000: 
                        begin
                            if (funct7[5] == 0) operation = ADD;
                            else operation = SUB;
                        end
                        3'b010: operation = SLT;
                        3'b110: operation = OR;
                        3'b111: operation = AND;
                    endcase
                end
                7'b0010011: // i-type
                begin
                    operation = ADDI;
                end
            endcase

            case(operation)
                ADD:  predicted_result = register_bank[rs1] + register_bank[rs2];
                SUB:  predicted_result = register_bank[rs1] - register_bank[rs2];
                AND:  predicted_result = register_bank[rs1] & register_bank[rs2];
                OR:   predicted_result = register_bank[rs1] | register_bank[rs2];
                SLT:  predicted_result = ($signed(register_bank[rs1]) < $signed(register_bank[rs2])) ? 32'hFFFFFFFF : 32'h00000000;
                ADDI: predicted_result = register_bank[rs1] + {{20{imm[11]}},imm};
            endcase

            register_bank[rd] = (rd == 0) ? 32'h00000000 : predicted_result;

            if (predicted_result !== bfm.result) $error("FAILED: rd: %2d  rs1: %2d  rs2: %2d  imm: %4d  op: %4s  result: 0x%8h  expected: 0x%8h", rd, rs1, rs2, imm, operation.name(), bfm.result, predicted_result);
            else $display("PASSED: rd: %2d  rs1: %2d  rs2: %2d  imm: %4d  op: %4s  result: 0x%8h  expected: 0x%8h", rd, rs1, rs2, imm, operation.name(), bfm.result, predicted_result);

        end : self_checker
    
    endtask : run_phase

endclass


