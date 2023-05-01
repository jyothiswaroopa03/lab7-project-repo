//=====================================================================
// Project: 4 core MESI cache design
// File Name: mix_icache_dcache.sv
// Description: Test for write same address to I-cache
// Designers: Venky & Suru
//=====================================================================

class mix_icache_dcache extends base_test;

    //component macro
    `uvm_component_utils(mix_icache_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mix_icache_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mix_icache_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : mix_icache_dcache


// Sequence for a write-same addr on I-cache
class mix_icache_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mix_icache_dcache_seq)
bit[31:0] addr;
    cpu_transaction_c trans;

    //constructor
    function new (string name="mix_icache_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(10) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; })
addr= trans.address;
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
addr=trans.address;
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})

    end
endtask

endclass : mix_icache_dcache_seq
