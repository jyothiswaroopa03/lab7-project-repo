//=====================================================================
// Project: 4 core MESI cache design
// File Name: rd_rd_wr.sv
// Description: Test for write same address to D-cache
// Designers: Venky & Suru
//=====================================================================

class rd_rd_wr extends base_test;

    //component macro
    `uvm_component_utils(rd_rd_wr)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", rd_rd_wr_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing rd_rd_wr test" , UVM_LOW)
    endtask: run_phase

endclass : rd_rd_wr


// Sequence for a write-same addr on D-cache
class rd_rd_wr_seq extends base_vseq;
    //object macro
    `uvm_object_utils(rd_rd_wr_seq)

    cpu_transaction_c trans;
	bit[31:0] addr;
    //constructor
    function new (string name="rd_rd_wr_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(1) begin 
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})

addr =trans.address;
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==addr;})
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address==addr;})


    end
endtask

endclass : rd_rd_wr_seq
