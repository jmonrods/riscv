module top_tb();

    logic clk;
    logic rst;

    top top1 (clk, rst);

    initial begin
        rst = 1;
        #10;
        rst = 0;

        #200 $finish();
    end

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end


endmodule
