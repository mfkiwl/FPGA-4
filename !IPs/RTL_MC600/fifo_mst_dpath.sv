//------------------------------------------------------------------------------
// Title        : fifo_mst_dpath.v 
// Project      : FT600
//------------------------------------------------------------------------------
// Author       : Wai Kwok 
// Date Created : 12th Mar,2014
//------------------------------------------------------------------------------
// Description  : 
//                FT600 FIFO Master data path 
//
//
//------------------------------------------------------------------------------
// Known issues & omissions:
// 
// 
//------------------------------------------------------------------------------
// Copyright 2013 FTDI Ltd. All rights reserved.
//------------------------------------------------------------------------------

module fifo_mst_dpath (

  // inputs
  input                				fifoRstn,
  input                				fifoClk,
  input                				latch_clk,
  input [WIDTH_DATA-1:0]         	tc_data,
  input [CNT_BE-1:0]          		tc_be,
  input                				tc_rxf_n,
  input                				tc_txe_n,
  input                				snd_cmd,
  input [CNT_BE-1:0]          		bus_cmd,
  input [WIDTH_DATA-1:0]         	tx_data,
  input [CNT_BE-1:0]          		tx_be,
  input [CNT_CODE_NUM_CHNLS:0]      ep_num,


  // outputs
  output reg [WIDTH_DATA-1:0]   	tp_data,
  output reg [CNT_BE-1:0]    		tp_be,
  output reg          				rx_rxf_n,
  output reg          				rx_txe_n,
  output reg [WIDTH_DATA-1:0]   	rx_data,
  output reg [CNT_BE-1:0]    		rx_be
);



  always_ff @(posedge fifoClk or negedge fifoRstn)
    if (~fifoRstn) begin

      tp_be     <=  '1;
      tp_data   <=  '1;

    end
    else begin

      if (snd_cmd) begin
        tp_be    <= bus_cmd;
        tp_data  <= {24'h00_0000,5'h00,ep_num};
      end
      else begin
        tp_be    <= tx_be;
        tp_data  <= tx_data;
      end

    end


// latch
  always @(latch_clk or tc_data)
    if (~latch_clk)
      rx_data <= tc_data; 

  always @(latch_clk or tc_be)
    if (~latch_clk)
      rx_be <= tc_be; 

  always @(latch_clk or tc_rxf_n)
    if (~latch_clk)
      rx_rxf_n <= tc_rxf_n; 

  always @(latch_clk or tc_txe_n)
    if (~latch_clk)
      rx_txe_n <= tc_txe_n; 


endmodule
