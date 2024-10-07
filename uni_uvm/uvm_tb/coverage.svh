// coverage: captures functional coverage information
class coverage extends uvm_component;
    `uvm_component_utils(coverage);

    virtual cpu_bfm bfm;

    covergroup cov_instr_operation;
        coverpoint bfm.instr[6:0] {
            bins rtype = {7'b0110011};
            bins itype = {7'b0010011};
        }
    endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
        cov_instr_operation = new();
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*", "bfm", bfm))
            $fatal("Failed to get BFM");
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        forever begin : sampling_block
            @(posedge bfm.clk) #1;
            cov_instr_operation.sample();
        end : sampling_block
    
    endtask : run_phase

endclass
