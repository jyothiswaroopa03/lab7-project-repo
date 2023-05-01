//=====================================================================
// Project: 4 core MESI cache design
// File Name: shared_test.sv
// Description: Test for 5 read to D-cache
// Designers: Venky & Suru
//=====================================================================

class shared_test extends base_test;

    //component macro
    `uvm_component_utils(shared_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", shared_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing shared_test" , UVM_LOW)
    endtask: run_phase

endclass : shared_test


// Sequence for a 5 read on D-cache
class shared_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(shared_test_seq)

    cpu_transaction_c trans;
//bit [29:0] offset;
//int i=randomize(offset);
 bit [1:0] core1,core2;
 bit [31:0] addr;

    //constructor
    function new (string name="shared_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(1)begin
		randomize(core1) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core2) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core2 inside {core1});};
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type == READ_REQ;access_cache_type == DCACHE_ACC;})
addr=trans.address;
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type == READ_REQ;access_cache_type == DCACHE_ACC; address==addr; })
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type == WRITE_REQ;access_cache_type == DCACHE_ACC; address==addr; })
    end
endtask

endclass : shared_test_seq
