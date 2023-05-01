//=====================================================================
// Project: 4 core MESI cache design
// File Name: inv_to_shared_check.sv
// Description: Test for write same address to I-cache
// Designers: Venky & Suru
//=====================================================================

class inv_to_shared_check extends base_test;

    //component macro
    `uvm_component_utils(inv_to_shared_check)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", inv_to_shared_check_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing inv_to_shared_check test" , UVM_LOW)
    endtask: run_phase

endclass : inv_to_shared_check


// Sequence for a write-same addr on I-cache
class inv_to_shared_check_seq extends base_vseq;
    //object macro
    `uvm_object_utils(inv_to_shared_check_seq)

    cpu_transaction_c trans;
bit[31:0] addr;
rand bit[1:0] core1,core2,core3,core4;
    //constructor
    function new (string name="inv_to_shared_check_seq");
        super.new(name);
    endfunction : new

    virtual task body();
randomize(core1) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core2) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core2 inside {core1});};
		randomize(core3) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core3 inside {core1,core2});};
		randomize(core4) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core4 inside {core1,core2,core3});};


repeat(1) begin
        
 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; })
addr=trans.address;
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})

    end
endtask

endclass : inv_to_shared_check_seq
