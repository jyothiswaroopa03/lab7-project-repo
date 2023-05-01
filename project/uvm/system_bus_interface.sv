//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
// Designers: Venky & Suru
//=====================================================================

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
    parameter NO_OF_CORE            = 4;

    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

//Assertions
//property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty

//ASSERTION1: lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))

//ASSERTION2: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
assert_data_in_bus_lv1_lv2_cp_in_cache: assert property (prop_sig1_before_sig2(lv2_rd,data_in_bus_lv1_lv2 && cp_in_cache))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_data_in_bus_lv1_lv2_cp_in_cache Failed: lv2_rd not asserted before data_in_bus_lv1_lv2 and cp_in_cache are asserted"))

//TODO: Add assertions at this interface
//There are atleast 20 such assertions. Add as many as you can!!

//ASSERTION3: lv2_rd should be followed by data_in_bus_lv1_lv2 and both should be deasserted acc to HAS
property valid_lv2_rd_txn;
    @(posedge clk)
        lv2_rd |=> ##[0:$] data_in_bus_lv1_lv2 ##1 !lv2_rd;
    endproperty
assert_valid_lv2_rd_txn: assert property (valid_lv2_rd_txn)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_lv2_rd_txn Failed: lv2_rd => data_in_bus_lv1_lv2 => !lv2_rd sequence is not followed"))

//ASSERTION4: If data_in_bus_lv1_lv2 is asserted, lv2_rd should be high
property valid_data_in_lv2_bus_rd;
    @(posedge clk)
        (data_in_bus_lv1_lv2 === 1'bz) ##1 (data_in_bus_lv1_lv2 ==1'b1) |-> lv2_rd;
    endproperty
assert_valid_data_in_lv2_bus_rd: assert property (valid_data_in_lv2_bus_rd)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_data_in_lv2_bus_rd Failed: lv2_rd is not high when data_in_bus_lv1_lv2 asserted"))

//ASSERTION5: lv2_wr should be followed by lv2_wr_done and both should be deasserted acc to HAS
property valid_lv2_wr_txn;
    @(posedge clk)
        (lv2_wr) |=> ##[0:$] lv2_wr_done ##1 !lv2_wr ##1 !lv2_wr_done;
    endproperty
assert_valid_lv2_wr_txn: assert property (valid_lv2_wr_txn)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_lv2_wr_txn Failed: lv2_wr => lv2_wr_done => !lv2_wr => !lv2_wr_done sequence is not followed"))


//ASSERTION6: all_invalidation_done should not be asserted without invalidate being asserted in the previous cycle

assert_invalidation_done: assert property (prop_sig1_before_sig2(invalidate, all_invalidation_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidation_done Failed: all_invalidation_done is asserted without invalidate being asserted in the previous cycle"))

//ASSERTION7: Copy in cache should be asserted only when bus_rd or bus_rdx in previous cycle
property prop_cp_in_cache;
@(posedge clk)
$rose(cp_in_cache) |=> $past(bus_rd||bus_rdx);
endproperty
assert_prop_cp_in_cache: assert property (prop_cp_in_cache)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_prop_cp_in_cache Failed: cp_in_cache asserted without previous bus_rd or bus_rdx"))

//ASSERTION8: bus_rd and bus_rdx must be asserted on processor receiving grant and lv2_rd
property valid_lv2_rd_rdx;
    @(posedge clk)
        (bus_lv1_lv2_gnt_proc && lv2_rd && addr_bus_lv1_lv2[31:30] !==2'b00) |-> (bus_rdx || bus_rd);
    endproperty
assert_valid_lv2_rd_rdx: assert property (valid_lv2_rd_rdx)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_lv2_rd_rdx Failed: lv2_rd on the processor that received grant should be followed by bus_rdx or bus_rd"))


//ASSERTION9:lv2_wr_done should be asserted in previous cycle before lv2_wr gets deasserted
    property valid_lv2_wr_done;
        @(posedge clk)
          $rose(lv2_wr_done) |-> (lv2_wr);
    endproperty

    assert_valid_lv2_wr_done: assert property (valid_lv2_wr_done)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_lv2_wr_done Failed: lv2_wr_done should be asserted in previous cycle before lv2_wr gets deasserted"))

//ASSERTION10: bus_lv1_lv2_req_snoop should be followed by bus_lv1_lv2_gnt_snoop acc to HAS
property valid_bus_lv1_lv2_req_snoop;
    @(posedge clk)
        (bus_lv1_lv2_req_snoop) |=> ##[0:$] bus_lv1_lv2_gnt_snoop;
    endproperty
assert_valid_bus_lv1_lv2_req_snoop: assert property (valid_bus_lv1_lv2_req_snoop)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_bus_lv1_lv2_req_snoop Failed: bus_lv1_lv2_req_snoop => bus_lv1_lv2_gnt_snoop is not followed"))

//ASSERTION11: bus_lv1_lv2_req_proc should be followed by bus_lv1_lv2_gnt_proc acc to HAS
property valid_bus_lv1_lv2_req_proc;
    @(posedge clk)
        (bus_lv1_lv2_req_proc) |=> ##[0:$] bus_lv1_lv2_gnt_proc;
    endproperty
assert_valid_bus_lv1_lv2_req_proc: assert property (valid_bus_lv1_lv2_req_proc)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_bus_lv1_lv2_req_proc Failed: bus_lv1_lv2_req_proc => bus_lv1_lv2_gnt_proc is not followed"))

//ASSERTION12: bus_rd and bus_rdx should not be asserted simultaneously
property valid_bus_rd_rdx;
    @(posedge clk)
		not(bus_rd && bus_rdx);
        endproperty
assert_valid_bus_rd_rdx: assert property (valid_bus_rd_rdx)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_bus_rd_rdx Failed: bus_rd and bus_rdx are asserted simultaneously"))

//ASSERTION13: All Processors snooping simultaneously
property simult_snoop_check;
    @(posedge clk)
		not(bus_lv1_lv2_req_snoop==4'b1111);
    endproperty
assert_simult_snoop_check: assert property (simult_snoop_check)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_simult_snoop_check Failed: All Processors are snooping simultaneously which should not happen as one processor should always request"))

//ASSERTION14: Invalidate should not be asserted without proccessor getting grant in previous cycle
property valid_inv_gnt;
@(posedge clk)
invalidate |-> $past(bus_lv1_lv2_gnt_proc) ;
endproperty
assert_valid_inv_gnt: assert property (valid_inv_gnt)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_valid_inv_gnt Failed: invalidate is asserted without processor grant"))

//ASSERTION15:  IF shared is asserted, data_in_bus_lv1_lv2 should be high (pg 9 HAS)

  property valid_shared_data_in_bus;
    @(posedge clk)
      (shared === 1'bz) ##1 (shared == 1'b1) |-> data_in_bus_lv1_lv2  ;
  endproperty
  
  assert_valid_shared_data_in_bus: assert property (valid_shared_data_in_bus)
  else
    `uvm_error("system_bus_interface", "Assertion valid_shared_data_in_bus failed : shared made high is not followed by data_in_bus_lv1_lv2 made high")    

//ASSERTION16: If data is put in data_bus_lv1_lv2, data_in_bus_lv1_lv2 should be made high immediately (pg 8/9 HAS)

property valid_data_in_data_bus;
  @(posedge clk)
     (data_bus_lv1_lv2 === 32'bz) ##1 (data_bus_lv1_lv2 != 32'bz) |->  data_in_bus_lv1_lv2;
endproperty

  assert_valid_data_in_data_bus: assert property (valid_data_in_data_bus)
  else
    `uvm_error("system_bus_interface", "Assertion valid_data_in_data_bus : data_in_bus_lv1_lv2 does not immediately become high when data is put in data_bus_lv1_lv2") 

//ASSERTION17: After all_invalidation_done is asserted , deassert invalidate (pg 14 HAS)

property valid_des_invalidate;
  @(posedge clk)
     $rose(all_invalidation_done) |=> $fell(invalidate);
endproperty

  assert_valid_des_invalidate: assert property (valid_des_invalidate)
  else
    `uvm_error("system_bus_interface", "Assertion valid_des_invalidate : invalidate is not desasserted in the next cycle as all_invalidation_done is asserted ") 
/*
//ASSERTION18: lv2_rd or bus_rdx or bus_rd should be deasserted after data_in_bus_lv1_lv2 being asserted. 
    property data_in_bus_rdx_rd;
        @(posedge clk)
	data_in_bus_lv1_lv2  && (addr_bus_lv1_lv2[31:30] !==2'b00)|=> not($stable(bus_rdx || bus_rd || lv2_rd));
    endproperty

    assert_data_in_bus_rdx_rd: assert property (data_in_bus_rdx_rd)
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_data_in_bus_rdx_rd Failed: lv2_rd or bus_rdx or bus_rd not deasserted after getting data_in_bus_lv1_lv2 "))
*/
//ASSERTION 19: Address should not be invalid when lv2_rd/wr request is processed
  property valid_addr_lv2_rd_wr;
    @(posedge clk)
      (lv2_rd || lv2_wr) |-> (addr_bus_lv1_lv2[31:0] !== 32'bx);
  endproperty
  
  assert_valid_addr_lv2_rd_wr: assert property (valid_addr_lv2_rd_wr)
  else
    `uvm_error("system_bus_interface", "Assertion valid_addr_lv2_rd_Wr failed: Address is X when lv2_rd/wr command is issued")

//ASSERTION 20: System bus grant should not be given to multiple processors at the same time
  property valid_proc_bus_gnt;
    @(posedge clk)
      (|(bus_lv1_lv2_gnt_proc)) |-> $onehot(bus_lv1_lv2_gnt_proc);
  endproperty
  
  assert_valid_proc_bus_gnt: assert property (valid_proc_bus_gnt)
  else
    `uvm_error("system_bus_interface", "Assertion valid_proc_bus_gnt failed: Bus grant given to multiple processors at the same time")

//ASSERTION 21: System bus grant should not be given to multiple snooping processors at the same time
  property valid_snoop_bus_gnt;
    @(posedge clk)
     (|(bus_lv1_lv2_gnt_snoop)) |-> $onehot(bus_lv1_lv2_gnt_snoop);
  endproperty
  
  assert_valid_snoop_bus_gnt: assert property (valid_snoop_bus_gnt)
  else
    `uvm_error("system_bus_interface", "Assertion valid_snoop_bus_gnt failed: Bus grant given to multiple snooping processors at the same time")

//ASSERTION22: bus_lv1_lv2_req_lv2 should not be asserted without lv2_rd or lv2_wr being asserted in previous cycle
assert_bus_lv1_lv2_req_lv2: assert property (prop_sig1_before_sig2(lv2_rd || lv2_wr,bus_lv1_lv2_req_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_req_lv2 Failed: bus_lv1_lv2_req_lv2 is asserted without lv2_rd or lv2_wr in the previous cycle"))

//ASSERTION23: bus_lv1_lv2_gnt_proc should be asserted only if previous bus_lv1_lv2_req_proc

assert_bus_lv1_lv2_req_gnt_proc: assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_proc,bus_lv1_lv2_gnt_proc))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_req_gnt_proc Failed: bus_lv1_lv2_gnt_proc did not have a previous bus_lv1_lv2_req_proc"))
 
//ASSERTION24: bus_lv1_lv2_gnt_snoop should be asserted only if previous bus_lv1_lv2_req_snoop

assert_bus_lv1_lv2_req_gnt_snoop: assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_proc,bus_lv1_lv2_gnt_snoop))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv1_lv2_req_gnt_snoop Failed: bus_lv1_lv2_gnt_snoop did not have a previous bus_lv1_lv2_req_snoop"))


//ASSERTION25: all_invalidation_done should be asserted only if previous invalidate

assert_invalidate_all_invalidation_done: assert property (prop_sig1_before_sig2(invalidate,all_invalidation_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_all_invalidation_done Failed: all_invalidation_done did not have a previous invalidate"))


//ASSERTION26: shared should be asserted only if previous bus_lv1_lv2_gnt_proc

assert_shared_bus_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_gnt_proc,shared))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_shared_bus_gnt Failed: shared did not have a previous bus_lv1_lv2_gnt_proc"))

//ASSERTION27: invalidate should be asserted only if previous bus_lv1_lv2_gnt_proc

assert_invalidate_bus_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_gnt_proc,invalidate))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_bus_gnt Failed: invalidate did not have a previous bus_lv1_lv2_gnt_proc"))

//ASSERTION28: bus_rd should be asserted only if previous bus_lv1_lv2_gnt_proc

assert_bus_rd_bus_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_gnt_proc,bus_rd))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_rd_bus_gnt Failed: bus_rd did not have a previous bus_lv1_lv2_gnt_proc"))

//ASSERTION29: bus_rdx should be asserted only if previous bus_lv1_lv2_gnt_proc

assert_bus_rdx_bus_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_gnt_proc,bus_rdx))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_rdx_bus_gnt Failed: bus_rdx did not have a previous bus_lv1_lv2_gnt_proc"))

//ASSERTION30: bus_lv1_lv2_gnt_lv2 should be asserted only if previous bus_lv1_lv2_req_lv2

assert_bus_lv2_req_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_lv2,bus_lv1_lv2_gnt_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_bus_lv2_req_gnt Failed: bus_lv1_lv2_gnt_lv2 did not have a previous bus_lv1_lv2_req_lv2"))

//ASSERTION31: data_in_bus_lv1_lv2 should be asserted only if previous bus_lv1_lv2_gnt_lv2 or bus_lv1_lv2_gnt_snoop

assert_data_in_bus_req_gnt: assert property (prop_sig1_before_sig2((bus_lv1_lv2_gnt_snoop || bus_lv1_lv2_gnt_lv2),data_in_bus_lv1_lv2))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_data_in_bus_req_gnt Failed: data_in_bus_lv1_lv2 did not have a previous bus_lv1_lv2_gnt_lv2 or gnt_snoop"))


endinterface




