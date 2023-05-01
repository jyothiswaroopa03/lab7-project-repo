//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_on_two_proc.sv
// Description: Test for read on two proc
// Designers: Venky & Suru
//=====================================================================

class read_on_two_proc extends base_test;

    //component macro
    `uvm_component_utils(read_on_two_proc)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_on_two_proc_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_on_two_proc test" , UVM_LOW)
    endtask: run_phase

endclass : read_on_two_proc


// Sequence for a read on two proc
class read_on_two_proc_seq extends base_vseq;
    //object macro
    `uvm_object_utils(read_on_two_proc_seq)

    cpu_transaction_c trans;
bit[1:0] core1, core2;
    //constructor
    function new (string name="read_on_two_proc_seq");
        super.new(name);
    endfunction : new

    virtual task body();
randomize(core1) with{ core1 inside {0,1,2,3};};
randomize(core2) with {!(core2 inside {core1}); core2 inside {0,1,2,3};};

repeat(5) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==32'h8765_4321;})
    end
repeat(5) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address==32'h8765_4321;})
    end
endtask

endclass : read_on_two_proc_seq