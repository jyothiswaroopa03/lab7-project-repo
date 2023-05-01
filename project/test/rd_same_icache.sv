//=====================================================================
// Project: 4 core MESI cache design
// File Name: rd_same_icache.sv
// Description: Test for read same address to I-cache
// Designers: Venky & Suru
//=====================================================================

class rd_same_icache extends base_test;

    //component macro
    `uvm_component_utils(rd_same_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", rd_same_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing rd_same_icache test" , UVM_LOW)
    endtask: run_phase

endclass : rd_same_icache


// Sequence for a read-same addr on I-cache
class rd_same_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(rd_same_icache_seq)
rand bit index[13:0];
bit[31:0] addr;
    cpu_transaction_c trans;

    //constructor
    function new (string name="rd_same_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
int i=randomize(index);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC;})
addr= trans.address;
repeat(10) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address==addr;})
    end
endtask

endclass : rd_same_icache_seq
