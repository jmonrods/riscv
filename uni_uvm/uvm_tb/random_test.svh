class random_test extends uvm_test;

    // register this test into the uvm factory
    `uvm_component_utils(random_test);

    // instantiate the tester class
    random_tester random_tester_h;
    coverage      coverage_h;
    scoreboard    scoreboard_h;

    // declare a virtual bfm, to be passed in the constructor
    virtual cpu_bfm bfm;

    // constructor
    function new (string name, uvm_component parent);
        
        // the next line is required by uvm
        super.new(name, parent);

        // use the get() method from uvm_config_db to acquire the bfm which was stored by top.sv
        if(!uvm_config_db #(virtual cpu_bfm)::get(null, "*", "bfm", bfm))
            $fatal("Failed to get BFM");

    endfunction : new

    function void build_phase(uvm_phase phase);

        // create new objects of the classes
        random_tester_h = new("tester_h",     this);
        coverage_h      = new("coverage_h",   this);
        scoreboard_h    = new("scoreboard_h", this);

    endfunction

endclass
