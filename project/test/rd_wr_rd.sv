//=====================================================================
// Project: 4 core MESI cache design
// File Name: rd_wr_rd.sv
// Description: Test for read-write-read to D-cache
// Designers: Venky & Suru
//=====================================================================

class rd_wr_rd extends base_test;

    //component macro
    `uvm_component_utils(rd_wr_rd)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", rd_wr_rd_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing rd_wr_rd test" , UVM_LOW)
    endtask: run_phase

endclass : rd_wr_rd


// Sequence for a read-miss on D-cache
class rd_wr_rd_seq extends base_vseq;
    //object macro
    `uvm_object_utils(rd_wr_rd_seq)

    cpu_transaction_c trans;
bit [31:0] addr;
bit [1:0] processor1,processor2,processor3;
    //constructor
    function new (string name="rd_wr_rd_seq");
        super.new(name);
    endfunction : new

    virtual task body();
		randomize(processor1) with { processor1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(processor2) with { processor1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(processor2 inside {processor1});};
		randomize(processor3) with { processor1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(processor3 inside {processor1,processor2});};
repeat(10) begin
//mp = $urandom_range(0,3);

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[processor1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
addr=trans.address;
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[processor2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == addr;})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[processor3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == addr;})
end    
endtask

endclass : rd_wr_rd_seq

