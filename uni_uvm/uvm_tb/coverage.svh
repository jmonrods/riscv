// coverage: captures functional coverage information
class coverage extends uvm_component;
    `uvm_component_utils(coverage);

    virtual cpu_bfm bfm;

    covergroup CovInsOp;
        coverpoint bfm.in.operation;
    endgroup

    covergroup cov_slt_results_true_false;
        coverpoint bfm.result {
            bins false = {32'h00000000};
            bins true  = {32'hFFFFFFFF};
        }
    endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
        CovInsOp = new();
        cov_slt_results_true_false = new();
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*", "bfm", bfm))
            $fatal("Failed to get BFM");
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        forever begin : sampling_block
            @(posedge bfm.clk) #1;
            CovInsOp.sample();
            if (bfm.in.operation == SLT) cov_slt_results_true_false.sample();
        end : sampling_block
    
    endtask : run_phase

endclass
