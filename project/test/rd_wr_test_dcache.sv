//=====================================================================
// Project: 4 core MESI cache design
// File Name: rd_wr_test_dcache.sv
// Description: Test for read followed by write to D-cache
// Designers: Venky & Suru
//=====================================================================

class rd_wr_test_dcache extends base_test;

    //component macro
    `uvm_component_utils(rd_wr_test_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", rd_wr_test_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing rd_wr_test_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : rd_wr_test_dcache


// Sequence for a read followed by write to D-cache
class rd_wr_test_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(rd_wr_test_dcache_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="rd_wr_test_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
    endtask

endclass : rd_wr_test_dcache_seq
