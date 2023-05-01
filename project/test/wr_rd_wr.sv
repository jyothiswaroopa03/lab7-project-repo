//=====================================================================
// Project: 4 core MESI cache design
// File Name: wr_rd_wr.sv
// Description: Test for write same address to D-cache
// Designers: Venky & Suru
//=====================================================================

class wr_rd_wr extends base_test;

    //component macro
    `uvm_component_utils(wr_rd_wr)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", wr_rd_wr_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing wr_rd_wr test" , UVM_LOW)
    endtask: run_phase

endclass : wr_rd_wr


// Sequence for a write-same addr on D-cache
class wr_rd_wr_seq extends base_vseq;
    //object macro
    `uvm_object_utils(wr_rd_wr_seq)
bit[31:0] addr;
    cpu_transaction_c trans;
bit [1:0] core1,core2,core3;
    //constructor
    function new (string name="wr_rd_wr_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(5) begin 
		randomize(core1) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1};};
		randomize(core2) with { core1 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core2 inside {core1});};
randomize(core3) with { core3 dist{0:=1, 1:=1, 2:=1, 3:=1}; !(core3 inside {core1,core2});};

//`uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==32'h8765_4321;})

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; })
addr=trans.address;
	 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	 `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==addr;})
	


    end
endtask

endclass : wr_rd_wr_seq
