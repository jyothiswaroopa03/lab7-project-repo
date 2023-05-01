//=====================================================================
// Project: 4 core MESI cache design
// File Name: lru_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class lru_icache extends base_test;

    //component macro
    `uvm_component_utils(lru_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru_icache test" , UVM_LOW)
    endtask: run_phase

endclass : lru_icache


// Sequence for a read-miss on I-cache
class lru_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru_icache_seq)

    cpu_transaction_c trans;
    bit [31:0] addr;
    bit [1:0] offset;
    bit [15:0] tag;
    bit [13:0] index_val;
    bit [1:0] p;

    //constructor

    function new (string name="lru_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	repeat(100) begin
	    p = $urandom_range(0,3);

	    index_val = $urandom();
		repeat(8)
		begin
		offset = $urandom_range(0.3);
	        tag = $urandom();
	        tag[15:14] = $urandom_range(0);
		addr = {tag,index_val,offset};
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[p], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == addr;})
		end
	end
    endtask

endclass : lru_icache_seq
