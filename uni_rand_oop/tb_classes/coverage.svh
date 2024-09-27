// coverage: captures functional coverage information
class coverage;

    virtual cpu_bfm bfm;

    covergroup CovInsOp;
		coverpoint bfm.in.operation;
	endgroup

    function new (virtual cpu_bfm b);
        bfm = b;
        CovInsOp = new();
    endfunction : new

    task execute();
      forever begin : sampling_block
         @(posedge bfm.clk) #1;
         CovInsOp.sample();
      end : sampling_block
   endtask : execute

endclass
