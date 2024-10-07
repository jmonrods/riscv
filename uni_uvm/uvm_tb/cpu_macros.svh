// define macro for randomization check
`define SV_RAND_CHECK(r) \
    do begin \
        if (!(r)) begin \
            $display("%s:%d: Randomization failed \"%s\"", \
            `__FILE__, `__LINE__, `"r`"); \
            $finish(); \
        end \
    end while (0)
