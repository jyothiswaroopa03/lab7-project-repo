//=====================================================================
// Project: 4 core MESI cache design
// File Name: multiple_proc_rd_icache.sv
// Description: Test for write same address to I-cache
// Designers: Venky & Suru
//=====================================================================

class multiple_proc_rd_icache extends base_test;

    //component macro
    `uvm_component_utils(multiple_proc_rd_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", multiple_proc_rd_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing multiple_proc_rd_icache test" , UVM_LOW)
    endtask: run_phase

endclass : multiple_proc_rd_icache


// Sequence for a write-same addr on I-cache
class multiple_proc_rd_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(multiple_proc_rd_icache_seq)

    cpu_transaction_c trans;
bit[31:0] addr;

    //constructor
    function new (string name="multiple_proc_rd_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(1) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; })
addr= trans.address;
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
	`uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
    end
endtask

endclass : multiple_proc_rd_icache_seq
