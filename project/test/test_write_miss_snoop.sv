//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_write_miss_snoop.sv
// Description: Test for write same address to D-cache
// Designers: Venky & Suru
//=====================================================================

class test_write_miss_snoop extends base_test;

    //component macro
    `uvm_component_utils(test_write_miss_snoop)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", test_write_miss_snoop_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing test_write_miss_snoop test" , UVM_LOW)
    endtask: run_phase

endclass : test_write_miss_snoop


// Sequence for a write-same addr on D-cache
class test_write_miss_snoop_seq extends base_vseq;
    //object macro
    `uvm_object_utils(test_write_miss_snoop_seq)

    cpu_transaction_c trans;
    bit [31:0] addr;
    //constructor
    function new (string name="test_write_miss_snoop_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(1) begin 
//`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
addr = trans.address;
	 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address== addr;})
       `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address== addr;})
	 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address== addr;})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address== addr;})
	


    end
endtask

endclass : test_write_miss_snoop_seq
