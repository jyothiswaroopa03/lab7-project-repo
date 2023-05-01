//=====================================================================
// Project: 4 core MESI cache design
// File Name: five_seq_test.sv
// Description: Test for 5 read to I-cache
// Designers: Venky & Suru
//=====================================================================

class five_seq_test extends base_test;

    //component macro
    `uvm_component_utils(five_seq_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", five_seq_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing five_seq_test" , UVM_LOW)
    endtask: run_phase

endclass : five_seq_test


// Sequence for a 5 read on I-cache
class five_seq_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(five_seq_test_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="five_seq_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(5)begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;})
    end
endtask

endclass : five_seq_test_seq
