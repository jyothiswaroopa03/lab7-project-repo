//=====================================================================
// Project: 4 core MESI cache design
// File Name: mesi_check.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class mesi_check extends base_test;

    //component macro
    `uvm_component_utils(mesi_check)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_check_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_check test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_check


// Sequence for a read-miss on I-cache
class mesi_check_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_check_seq)

    cpu_transaction_c trans;
    bit [31:0] addr;
    bit [2:0] req_type;
    bit [1:0] op1,op2,op3;
    bit [1:0] core1,core2;

    //constructor
    function new (string name="mesi_check_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	repeat(1000)
begin
		req_type = $urandom_range(0,7);
		op1 = $urandom_range(0,2);
		randomize(op2) with {!(op2 inside {op1}); op2 inside {0,1,2};};
		randomize(op3) with {!(op3 inside {op1,op2}); op3 inside {0,1,2};};

		randomize(core1) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core2) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core2 inside {core1});};

		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type==req_type[op1];access_cache_type == DCACHE_ACC;})
		addr = trans.address;
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type==req_type[op2];access_cache_type == DCACHE_ACC; address == addr;})
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type==req_type[op3];access_cache_type == DCACHE_ACC; address == addr;})
end
    endtask

endclass : mesi_check_seq
