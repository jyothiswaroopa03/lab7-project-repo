//=====================================================================
// Project: 4 core MESI cache design
// File Name: wr_wr_rd.sv
// Description: Test for write same address to D-cache
// Designers: Venky & Suru
//=====================================================================

class wr_wr_rd extends base_test;

    //component macro
    `uvm_component_utils(wr_wr_rd)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", wr_wr_rd_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing wr_wr_rd test" , UVM_LOW)
    endtask: run_phase

endclass : wr_wr_rd


// Sequence for a write-same addr on D-cache
class wr_wr_rd_seq extends base_vseq;
    //object macro
    `uvm_object_utils(wr_wr_rd_seq)

    cpu_transaction_c trans;
	bit[31:0] addr;
    //constructor
    function new (string name="wr_wr_rd_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(5) begin 
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;})
addr = trans.address;
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==addr;})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})


    end
endtask

endclass : wr_wr_rd_seq
