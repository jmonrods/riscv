class random_test extends uvm_test;

    // register this test into the uvm factory
    `uvm_component_utils(random_test);

    // declare a virtual bfm, to be passed in the constructor
    virtual interface cpu_bfm bfm;

    // constructor
    function new (string_name. uvm_component_parent);
        
        // the next line is required by uvm
        super.new(name,parent);

        // use the get() method from uvm_config_db to acquire the bfm which was stored by top.sv
        if(!uvm_config_db #virtual interface cpu_bfm)::get(null, "*", "bfm", bfm)
            $fatal("Failed to get BFM");

    endfunction : new


    // now we write the code for the random test
    task run_phase(uvm_phase phase);

        // instantiate the tester class
        random_tester random_tester_h;
        coverage      coverage_h;
        scoreboard    scoreboard_h;

        // we make the test active by raising an objection (test cannot stop if an objection is raised)
        phase.raise_objection(this);

        // create new objects of the classes
        random_tester_h = new(bfm);
        coverage_h      = new(bfm);
        scoreboard_h    = new(bfm);

        // run the coverage and scoreboard in the background (parallel threads)
        fork
            coverage_h.execute();
            scoreboard_h.execute();
        join_none

        // run the random test in the front
        random_tester_h.execute();

        // if all is done, drop the objection (test can stop since now there is no objection to stop it)
        phase.drop_objection(this);

    endtask : run_phase

endclass
