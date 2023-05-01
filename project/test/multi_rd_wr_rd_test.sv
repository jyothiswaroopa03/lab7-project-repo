//=====================================================================
// Project: 4 core MESI cache design
// File Name: multi_rd_wr_rd_test.sv
// Description: Test for write same address to D-cache
// Designers: Venky & Suru
//=====================================================================

class multi_rd_wr_rd_test extends base_test;

    //component macro
    `uvm_component_utils(multi_rd_wr_rd_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", multi_rd_wr_rd_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing multi_rd_wr_rd_test test" , UVM_LOW)
    endtask: run_phase

endclass : multi_rd_wr_rd_test


// Sequence for a write-same addr on D-cache
class multi_rd_wr_rd_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(multi_rd_wr_rd_test_seq)

    cpu_transaction_c trans;
	bit[31:0] addr;
     rand bit [13:0] index;

    //constructor
    function new (string name="multi_rd_wr_rd_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();

repeat(100)begin
       `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type== READ_REQ; access_cache_type == DCACHE_ACC; address == {address[31:16],index,address[1:0]};})
end
`uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type== WRITE_REQ; access_cache_type == DCACHE_ACC; address == {address[31:16],index,address[1:0]};})
repeat(100)begin
       `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {request_type== READ_REQ; access_cache_type == DCACHE_ACC; address == {address[31:16],index,address[1:0]};})
end
endtask

endclass : multi_rd_wr_rd_test_seq
