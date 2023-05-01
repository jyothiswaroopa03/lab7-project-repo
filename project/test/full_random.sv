//=====================================================================
// Project: 4 core MESI cache design
// File Name: full_random.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class full_random extends base_test;

    //component macro
    `uvm_component_utils(full_random)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", full_random_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing full_random test" , UVM_LOW)
    endtask: run_phase

endclass : full_random


// Sequence for a read-miss on I-cache
class full_random_seq extends base_vseq;
    //object macro
    `uvm_object_utils(full_random_seq)

    cpu_transaction_c trans;
    bit [31:0] addr;
    bit [1:0] core1,core2,core3,core4;
    bit [2:0] op1,op2,op3,op4;
    bit [15:0] req_type;


    //constructor
    function new (string name="full_random_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	repeat(300) begin

		req_type = $urandom_range(0,15);
		op1 = $urandom_range(0,3);
		randomize(op2) with {op2 inside {0,1,2,3};};
		randomize(op3) with {op3 inside {0,1,2,3};};
		randomize(op4) with {op4 inside {0,1,2,3};};

		randomize(core1) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core2) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core3) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core4) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type ==req_type[op1] ; access_cache_type == DCACHE_ACC;})
		addr = trans.address;
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type ==req_type[op2]; access_cache_type == DCACHE_ACC; address == addr;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core3], {request_type ==req_type[op3]; access_cache_type == DCACHE_ACC; address == addr;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core4], {request_type ==req_type[op4]; access_cache_type == DCACHE_ACC; address == addr;})

	end
    endtask

endclass : full_random_seq
