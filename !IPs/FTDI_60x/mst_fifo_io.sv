/*
  File Name     : mst_fifo_io.v 
  Department    : IC Design, FTDI SGP
  Author        : Do Ngoc Duong
  History       : 25 April 2016 - Modify from fifo_mst_io.v of Kwok Wai  

  Description   : This module control the input, output delay of FPGA  
*/
module mst_fifo_io (
  //GPIO Control Signals
  input  HRST_N,
  input  SRST_N,
  input  MLTCN, // 1: Multi Channel Mode, 0: 245 Mode 
  input  STREN, // 1: Streaming Test,     0: Loopback Test
  input  ERDIS, // 1: Disable received data sequence check 
  input  [CNT_CHANNLS-1:0] MST_RD_N,	//In 245 Mode, only MST_RD_N[0] is valid 
  input  [CNT_CHANNLS-1:0] MST_WR_N,   //In 245 Mode, only MST_WR_N[0] is valid 
  input  R_OOB,
  input  W_OOB, 
  // FIFO Slave interface 
  input  CLK,
  inout  [WIDTH_DATA-1:0] DATA,
  inout  [CNT_BE-1:0] BE,
  input  RXF_N,   	// ACK_N
  input  TXE_N,
  output  WR_N,    // REQ_N
  output  SIWU_N,
  output  RD_N,
  output  OE_N,
  // Miscellaneous Interface 
  output  [CNT_CHANNLS-1:0] debug_sig,
  output  [CNT_CHANNLS-1:0] seq_err, 
  
  // From chip internal (from FPGA to FT60x )
  input  [WIDTH_DATA-1:0] tp_data	,
  input  [CNT_BE-1:0]  tp_be		,
  input  tp_dt_oe_n		,
  input  tp_be_oe_n		,
  input  tp_siwu_n		,
  input  tp_wr_n		,     // tp_req_n
  input  tp_rd_n		,
  input  tp_oe_n		,
  // 
  input  [CNT_CHANNLS-1:0] 	tp_debug_sig,  
  input  [CNT_CHANNLS-1:0] 	tp_seq_err, 
  
  // To chip internal (from FT60x to FPGA )
  output  [WIDTH_DATA-1:0] 	tc_data		,
  output  [CNT_BE-1:0]  	tc_be		,
  output  					tc_rst_n	,
  output  					tc_clk		,
  output  					tc_txe_n	,
  output  					tc_rxf_n	,
  //
  output  tc_mltcn,
  output  tc_stren,
  output  tc_erdis,  
  output  tc_r_oob,
  output  tc_w_oob,  
  output  [CNT_CHANNLS-1:0] tc_mst_rd_n,
  output  [CNT_CHANNLS-1:0] tc_mst_wr_n
);
  // 
  `ifdef FTDI_SIM 
  localparam INP_DLY  = 2ns;
  localparam OUT_DLY  = 2.5ns;
  localparam CLK_DLY  = 4ns;
  `else 
  localparam INP_DLY  = 0;
  localparam OUT_DLY  = 0;
  localparam CLK_DLY  = 0;
  `endif 
  // Clock 
  assign #CLK_DLY tc_clk 	= CLK; 
  // data
  assign #INP_DLY tc_data[7:0]  = DATA[7:0];
  assign #INP_DLY tc_data[15:8] = DATA[15:8];
  assign #INP_DLY tc_data[31:16]= DATA[31:16];
  assign #INP_DLY tc_be  		= BE;
  // 
  assign #OUT_DLY DATA[7:0] 	= ~tp_be_oe_n ? tp_data[7:0] 	: 'z;
  assign #OUT_DLY DATA[15:8] 	= ~tp_dt_oe_n ? tp_data[15:8] 	: 'z;
  assign #OUT_DLY DATA[31:16] 	= ~tp_be_oe_n ? tp_data[31:16] 	: 'z;
  assign #OUT_DLY BE 			= ~tp_be_oe_n ? tp_be 			: 'z;
  // control  
  assign #INP_DLY tc_txe_n 		= TXE_N;
  assign #INP_DLY tc_rxf_n 		= RXF_N;
  //                        	
  assign #OUT_DLY SIWU_N  		= tp_siwu_n;
  assign #OUT_DLY WR_N 			= tp_wr_n;
  assign #OUT_DLY RD_N    		= tp_rd_n;
  assign #OUT_DLY OE_N    		= tp_oe_n;
  //GPIO Control  
  assign tc_rst_n 		= SRST_N & HRST_N; 
  assign tc_mltcn		= MLTCN;
  assign tc_stren		= STREN;
  assign tc_erdis		= ERDIS;  
  assign tc_r_oob		= R_OOB; 
  assign tc_w_oob		= W_OOB; 
  assign tc_mst_rd_n	= MST_RD_N;
  assign tc_mst_wr_n	= MST_WR_N;
  assign debug_sig		= tp_debug_sig;	
  assign seq_err		= tp_seq_err;
  //
endmodule 
