// coverage: captures functional coverage information
class coverage;

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

    function new (virtual cpu_bfm b);
        bfm = b;
        CovInsOp = new();
        cov_slt_results_true_false = new();
    endfunction : new

    task execute();
        forever begin : sampling_block
            @(posedge bfm.clk) #1;
            CovInsOp.sample();
            if (bfm.in.operation == SLT) cov_slt_results_true_false.sample();
        end : sampling_block
    endtask : execute

endclass
