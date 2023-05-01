//=====================================================================
// Project: 4 core MESI cache design
// File Name: lru_test.sv
// Description: Test for 5 read to D-cache
// Designers: Venky & Suru
//=====================================================================

class lru_test extends base_test;

    //component macro
    `uvm_component_utils(lru_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru_test" , UVM_LOW)
    endtask: run_phase

endclass : lru_test


// Sequence for a 5 read on D-cache
class lru_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru_test_seq)

    cpu_transaction_c trans;
rand bit [13:0] index;
int i=randomize(index);
bit[1:0] core1,core2,core3,core4;

    //constructor
    function new (string name="lru_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();


repeat(100)begin
randomize(core1) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core2) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core2 inside {core1});};
		randomize(core3) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core3 inside {core1,core2});};
		randomize(core4) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core4 inside {core1,core2,core3});};
       // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type== READ_REQ; access_cache_type == DCACHE_ACC; address == {address[31:16],index,address[1:0]};})
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type== WRITE_REQ;access_cache_type == DCACHE_ACC; address == {address[31:16],index, address[1:0]};})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type== WRITE_REQ;access_cache_type == DCACHE_ACC; address == {address[31:16],index, address[1:0]};})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core3], {request_type== WRITE_REQ;access_cache_type == DCACHE_ACC; address == {address[31:16],index, address[1:0]};})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core4], {request_type== WRITE_REQ;access_cache_type == DCACHE_ACC; address == {address[31:16],index, address[1:0]};})
    end
endtask

endclass : lru_test_seq
