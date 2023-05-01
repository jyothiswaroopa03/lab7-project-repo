//=====================================================================
// Project: 4 core MESI cache design
// File Name: test.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class test extends base_test;

    //component macro
    `uvm_component_utils(test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing test test" , UVM_LOW)
    endtask: run_phase

endclass : test


// Sequence for a read-miss on I-cache
class test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(test_seq)

    cpu_transaction_c trans;
   rand bit [13:0] index;
int i=randomize(index);
    //constructor
    function new (string name="test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
	repeat(10)
begin
		
		`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type==WRITE_REQ;access_cache_type == DCACHE_ACC; address == {address[31:16], index, 2'b00};})

		end
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type==WRITE_REQ;access_cache_type == DCACHE_ACC; address == {address[31:16], index, 2'b01};})
    endtask

endclass : test_seq
