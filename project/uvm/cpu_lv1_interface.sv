//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
// Designers: Venky & Suru
//=====================================================================


interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg    ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

//Assertions

//ASSERTION1: cpu_wr and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

//TODO: Add assertions at this interface
//ASSERTION2: Address should not be invalid when rd/wr request is processed
    property valid_addr_wr_rd;
        @(posedge clk)
          (cpu_rd || cpu_wr) |-> (addr_bus_cpu_lv1[31:0] !== 32'bx);
    endproperty

    assert_valid_addr_wr_rd: assert property (valid_addr_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_addr_wr_rd Failed: address is not valid when wr/rd request is processed"))

//ASSERTION3: cpu_rd should be followed by data_in_bus_cpu_lv1 and both should be deasserted 
    property valid_rd_txn;
        @(posedge clk)
          (cpu_rd) |-> ##[0:$] data_in_bus_cpu_lv1 ##1 !cpu_rd ##1 !data_in_bus_cpu_lv1;
    endproperty

    assert_valid_rd_txn: assert property (valid_rd_txn)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_rd_txn Failed: (cpu_rd) -> data_in_bus_cpu_lv1 -> !cpu_rd -> !data_in_bus_cpu_lv1 sequence not followed"))


//ASSERTION4:If data_in_bus_cpu_lv1 is asserted, cpu_rd should be high
    property valid_data_in_bus_rd;
        @(posedge clk)
          $rose (data_in_bus_cpu_lv1) |-> cpu_rd;
    endproperty

    assert_valid_data_in_bus_rd: assert property (valid_data_in_bus_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_data_in_bus_rd Failed: (cpu_rd) is not high when data_in_bus_cpu_lv1 is asserted"))

//ASSERTION5: cpu_wr should be followed by cp_wr_done then both should be deasserted from pg 14 HAS

  property valid_cpu_wr_done_seq;
    @(posedge clk)
      cpu_wr |=> ##[0:$] cpu_wr_done ##1 !cpu_wr ##1 !cpu_wr_done;
  endproperty
  
  assert_valid_cpu_wr_done_seq: assert property (valid_cpu_wr_done_seq)
  else
    `uvm_error("cpu_lv1_interface", "Assertion valid_cpu_wr_done_seq failed: cpu_wrdone is not asserted after cpu_wr is asserted then cpu_wr should be deasserted then cpu_wr_done should be deasserted ")

//ASSERTION6: Assertion to check cpu_wr_done is asserted within 100 cycles of asserting cpu_wr
    
property cpu_wr_done_timeout_check;
	@(posedge clk)
	  cpu_wr |-> ##[0:100] cpu_wr_done;
    endproperty 

assert_cpu_wr_done_timeout_check: assert property(cpu_wr_done_timeout_check)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done_timeout_check Failed: cpu_wr_done not asserted within 100 cycles of cpu_wr assertion"))

//ASSERTION7: Assertion to check data_in_bus_cpu_lv1 is asserted within 100 cycles of asserting cpu_rd
    
property data_in_bus_timeout_check;
	@(posedge clk)
	  cpu_rd |-> ##[0:100] data_in_bus_cpu_lv1;
    endproperty 

assert_data_in_bus_timeout_check: assert property(data_in_bus_timeout_check)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_in_bus_timeout_check Failed: data_in_bus_cpu_lv1 not asserted within 100 cycles of cpu_rd assertion"))

//ASSERTION8: cpu_wr_done and data_in_bus_cpu_lv1 should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_done_data_in_bus;
        @(posedge clk)
          not(cpu_wr_done && data_in_bus_cpu_lv1);
    endproperty

    assert_prop_simult_cpu_wr_done_data_in_bus: assert property (prop_simult_cpu_wr_done_data_in_bus)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_prop_simult_cpu_wr_done_data_in_bus Failed: cpu_wr_done and data_in_bus_cpu_lv1 asserted simultaneously"))

//ASSERTION9: cpu_wr_done and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_done_cpu_rd;
        @(posedge clk)
          not(cpu_wr_done && cpu_rd);
    endproperty

    assert_prop_simult_cpu_wr_done_cpu_rd: assert property (prop_simult_cpu_wr_done_cpu_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_prop_simult_cpu_wr_done_cpu_rd Failed: cpu_wr_done and cpu_rd asserted simultaneously"))

//ASSERTION10: cpu_wr and data_in_bus_cpu_lv1 should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_data_in_bus;
        @(posedge clk)
          not(cpu_wr && data_in_bus_cpu_lv1);
    endproperty

    assert_prop_simult_cpu_wr_data_in_bus: assert property (prop_simult_cpu_wr_data_in_bus)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_prop_simult_cpu_wr_data_in_bus Failed: cpu_wr and data_in_bus_cpu_lv1 asserted simultaneously"))

//ASSERTION11: Assertion to check no cpu_wr on I-cache
    
property valid_cpu_wr_on_cache;
	@(posedge clk)
	  (addr_bus_cpu_lv1 < 32'h4000_0000) |-> !(cpu_wr);
    endproperty 

assert_valid_cpu_wr_on_cache: assert property(valid_cpu_wr_on_cache)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_cpu_wr_on_cache Failed: cpu_wr asserted on I-Cache"))

//ASSERTION12: Assertion to check data_in_bus_cpu_lv1 asserted with a previous cpu_rd signal
    
property valid_data_in_bus;
	@(posedge clk)
	  $rose(data_in_bus_cpu_lv1) |-> $past(cpu_rd);
    endproperty 

assert_valid_data_in_bus: assert property(valid_data_in_bus)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_data_in_bus Failed: data_in_bus_cpu_lv1 asserted without previous cpu_rd"))


//ASSERTION13: Assertion to check data_in_bus_cpu_lv1 assertion results in deassertion of cpu_rd signal
    
property cpu_rd_deassert;
	@(posedge clk)
	  $rose(data_in_bus_cpu_lv1) |=> $fell(cpu_rd);
    endproperty 

assert_cpu_rd_deassert: assert property(cpu_rd_deassert)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_rd_deassert Failed: data_in_bus_cpu_lv1 asserted but cpu_rd is not deasserted"))

//ASSERTION14: Assertion to check cpu_wr_done assertion results in deassertion of cpu_wr signal
    
property cpu_wr_deassert;
	@(posedge clk)
	  $rose(cpu_wr_done) |=> $fell(cpu_wr);
    endproperty 

assert_cpu_wr_deassert: assert property(cpu_wr_deassert)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_deassert Failed: cpu_wr_done asserted but cpu_wr is not deasserted"))

//ASSERTION15: Assertion to check cpu_wr_done asserted with a previous cpu_wr signal
    
property valid_cpu_wr_done;
	@(posedge clk)
	  $rose(cpu_wr_done) |-> $past(cpu_wr);
    endproperty 

assert_valid_cpu_wr_done: assert property(valid_cpu_wr_done)
    else
	`uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_valid_cpu_wr_done Failed: cpu_wr_done asserted without previous cpu_wr"))




endinterface
