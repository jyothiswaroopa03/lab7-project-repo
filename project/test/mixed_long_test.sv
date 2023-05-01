//=====================================================================
// Project: 4 core MESI cache design
// File Name: mixed_long_test.sv
// Description: Test for read followed by write to D-cache
// Designers: Venky & Suru
//=====================================================================

class mixed_long_test extends base_test;

    //component macro
    `uvm_component_utils(mixed_long_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mixed_long_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mixed_long_test test" , UVM_LOW)
    endtask: run_phase

endclass : mixed_long_test


// Sequence for a read followed by write to D-cache
class mixed_long_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mixed_long_test_seq)
bit[31:0] addr;

    cpu_transaction_c trans;

    //constructor
    function new (string name="mixed_long_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
repeat(10) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;})
addr=trans.address;
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC;address==addr;})
   end
 endtask

endclass : mixed_long_test_seq
