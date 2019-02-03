/*
  File Name     : mst_fifo_top.v 
  Department    : IC Design, FTDI SGP
  Author        : Do Ngoc Duong 
  History       : 25 April 2016 - Initial Version 

  Description   : This is the top module of Master FIFO bus  
*/

import pkg_adc_defines::*;
import pkg_ft601_ctrl_defines::*;

module mst_fifo_ft60x_ctrl
// #
// (
// WIDTH_DATA   		= 32,
// WIDTH_PREF_DATA 	= 36,
// CNT_BE				= 4,
// CNT_CHANNLS 		= 4,
// CNT_CODE_NUM_CHNLS	= $clog2(CNT_CHANNLS) , // = 2,

// WIDTH_MEM_ADR 		= 14

// )
(
  //GPIO Control Signals
  input HRST_N, //Hard Reset
  input SRST_N, //Soft Reset
  input MLTCN, // 1: Multi Channel Mode, 0: 245 Mode 
  input STREN, // 1: Streaming Test,     0: Loopback Test
  input ERDIS, // 1: Disable received data sequence check  
  input R_OOB, //Read Out-Of-Band – 245 Mode Once asserted to high while TXE_N being low, the master writes 1 byte then stops writing regardless of the state of TXE_N until R_OOB negates
  input W_OOB, //Write Out-Of-Band – 245 Mode Once asserted to high, master reads and discards data as long as RXF_N is asserted. RXF_N may assert multiple times while W_OOB is asserted 
  input WAKEUP_N, //Suspend/Remote Wakeup pin by default Low when USB is active, high when USB is in suspend. Application can drive this pin low in in USB suspend to generate a remote wakeup signal to the USB host.
  
  // FIFO Slave interface (Phy_Interface) 
  input  CLK,
  inout  [WIDTH_DATA-1:0] DATA,
  inout  [CNT_BE-1:0] BE,
  input  RXF_N,    // ACK_N
  input  TXE_N,
  output WR_N,    // REQ_N
  output SIWU_N, //
  output RD_N,
  output OE_N,
  // Miscellaneous Interface 
  output [CNT_CHANNLS-1:0] debug_sig,
  output [CNT_CHANNLS-1:0] STRER
);

  assign debug_sig[0]   			= WAKEUP_N; 
  assign debug_sig[CNT_CHANNLS-1:1] = 3'b101;
  
  wire [WIDTH_DATA-1:0] tp_data;
  wire [CNT_BE-1:0]  	tp_be;
  wire tp_dt_oe_n;
  wire tp_be_oe_n;
  wire tp_siwu_n;
  wire tp_wr_n;     // tp_req_n
  wire tp_rd_n;
  wire tp_oe_n;
  // 
  wire [CNT_CHANNLS-1:0] 	tp_debug_sig;
  wire [CNT_CHANNLS-1:0] 	tp_seq_err;
  // To chip internal 
  wire [WIDTH_DATA-1:0] 	tc_data;
  wire [CNT_BE-1:0]  		tc_be;
  wire tc_rst_n;
  wire tc_clk;
  wire tc_txe_n;
  wire tc_rxf_n;
  //
  wire tc_mltcn;
  wire tc_stren;
  wire tc_bus16;
  wire tc_erdis;
  wire tc_r_oob;
  wire tc_w_oob;
  wire [CNT_CHANNLS-1:0] tc_mst_rd_n;
  wire [CNT_CHANNLS-1:0] tc_mst_wr_n; 
  // 
  mst_fifo_io inst_io 
  (
    //GPIO Control Signals
  `ifdef ALTERA_FPGA 	 	 
    .HRST_N	(HRST_N),
    .SRST_N	(SRST_N),
  `else 
    .HRST_N	(HRST_N),
    .SRST_N	(!SRST_N),
  `endif 
    .MLTCN	, 
    .STREN	, 
    .ERDIS	, 
    .MST_RD_N	('0),   
    .MST_WR_N	('0), 
    .R_OOB	, 
    .W_OOB	, 
    // FIFO Slave interface 
    //inputs
	.CLK	,
    .DATA	,
    .BE		,
    .RXF_N	,  
    .TXE_N	,
	//ouputs
    .WR_N	,
    .SIWU_N	,
    .RD_N	,
    .OE_N	,
    // Miscellaneous Interface 
    .debug_sig	(), //(debug_sig),
    .seq_err	(STRER),
	
    // From chip internal (from FT60x to FPGA )
	//inputs
    .tp_data	,
    .tp_be		,
    .tp_dt_oe_n	,
    .tp_be_oe_n	,
    .tp_siwu_n	,
    .tp_wr_n	,
    .tp_rd_n	,
    .tp_oe_n	,
    // 
    .tp_debug_sig(tp_debug_sig),
    .tp_seq_err	(tp_seq_err),
    
	// To chip internal (from FPGA to FT60x)
	
	//outputs
    .tc_data		,
    .tc_be			,
    .tc_rst_n		,
    .tc_clk			,
    .tc_txe_n		,
    .tc_rxf_n		,
    //          	
    .tc_mltcn		,
    .tc_stren		,
    .tc_erdis		,
    .tc_r_oob		,
    .tc_w_oob		,
    .tc_mst_rd_n	,
    .tc_mst_wr_n	
  );

  wire ch_vld[CNT_CHANNLS];

  wire [WIDTH_DATA-1:0] chk_data;
  // 
  wire ch_req			[CNT_CHANNLS];

  wire [WIDTH_DATA-1:0] ch_dat[CNT_CHANNLS];

  wire i_fifo_rd;
  wire i_fifo_wr;
  wire [CNT_CODE_NUM_CHNLS-1:0] i_fifo_wr_id;
  wire [CNT_CHANNLS-1:0] 		i_fifo_afull;
  wire [CNT_CHANNLS-1:0] 		i_fifo_nempt;
  wire [WIDTH_PREF_DATA-1:0] 	i_fifo_wdat;
  wire [WIDTH_PREF_DATA-1:0] 	i_fifo_rdat;
  //
  wire pref_ena;
  wire pref_req;
  wire pref_mod;
  wire[ CNT_CODE_NUM_CHNLS-1:0]  	pref_chn;
  wire[ CNT_CHANNLS-1:0]  			pref_nempt;
  wire[WIDTH_PREF_DATA-1:0]  		pref_dout; 
 //
  mst_fifo_fsm inst_fsm 
  (
    // IO interface 
    .rst_n		(tc_rst_n),
    .clk		(tc_clk),
    .txe_n		(tc_txe_n),
    .rxf_n		(tc_rxf_n),
    .idata		(tc_data),
    .ibe		(tc_be),
    //      	
    .mltcn		(tc_mltcn),
    .stren		(tc_stren),
    .r_oob		(tc_r_oob),
    .w_oob		(tc_w_oob),
    .mst_rd_n	(tc_mst_rd_n),
    .mst_wr_n	(tc_mst_wr_n), 
    // 
    .odata	 	(tp_data),
    .obe	 	(tp_be),
    .dt_oe_n 	(tp_dt_oe_n),
    .be_oe_n 	(tp_be_oe_n),
    .siwu_n	 	(tp_siwu_n),
    .wr_n	 	(tp_wr_n),
    .rd_n	 	(tp_rd_n),
    .oe_n	 	(tp_oe_n),
    // 
    .tp_debug_sig,
    // Check Data interface 
    .ch_vld	,
    .chk_data	,
    .chk_err	(tp_seq_err),
    // internal FIFO control interface 
    .i_fifo_afull	,
    .i_fifo_nempt	,
    .i_fifo_wr	    ,
    .i_fifo_wr_id	,
    .i_fifo_wdat	,
    //
    .pref_ena   ,
    .pref_req   ,
    .pref_mod   ,
    .pref_chn   ,
    .pref_nempt ,
    .pref_dout  
  );
  //
   mst_pre_fet inst_pref 
   (
    .clk      (tc_clk),
    .rst_n    (tc_rst_n),
     //Flow control interface
    .pref_ena  	, 
    .pref_req  	, 
    .pref_mod  	,
    .pref_chn  	,    
    .pref_nempt	,    
    .pref_dout 	,   
     //Internal FIFO interface  
    .i_fifo_rd  	(i_fifo_rd),
    .i_fifo_nempt  	(i_fifo_nempt),    
    .i_fifo_dat 	(i_fifo_rdat),  
     //Streaming generate interface 
    .gen_req  (ch_req),  
	.gen_dat  (ch_dat)
 
     );
  // 
  wire chk_rst_n;
  assign chk_rst_n = (!tc_w_oob) & tc_rst_n;
  assign tc_bus16  = 1'b0;
  // 
  mst_data_chk inst_chk
  (
    .rst_n	(chk_rst_n),
    .clk	(tc_clk),
    .bus16	(tc_bus16),
    .erdis 	(tc_erdis), 
	
    .ch_vld	,
    .rdata	(chk_data),
    .seq_err	(tp_seq_err) 
  );
  //
  wire gen_rst_n;
  assign gen_rst_n = (!tc_r_oob) & tc_rst_n;
  // 
  mst_data_gen inst_gen
  (
    .rst_n	(gen_rst_n),
    .clk	(tc_clk),
    .bus16	(tc_bus16),
    .ch_req	,
	.ch_dat	

  ); 
  // 
  wire 							mem_w;       
  wire [WIDTH_MEM_ADR-1:0] 		mem_a;
  wire [WIDTH_PREF_DATA-1:0] 	mem_d;   
  wire [WIDTH_PREF_DATA-1:0] 	mem_q; 
  //  
  mst_fifo_ctl inst_ctl
  (
    .clk	(tc_clk),
    .rst_n	(tc_rst_n),
    .mltcn	(tc_mltcn),
    //FIFO control 
    .fifo_rd		(i_fifo_rd),
    .fifo_rd_id		(pref_chn),
    
	.fifo_wr		(i_fifo_wr),
    .fifo_wr_id		(i_fifo_wr_id),
    
	.fifo_afull		(i_fifo_afull),
    .fifo_nempt		(i_fifo_nempt),
    .fifo_din		(i_fifo_wdat),
    .fifo_dout		(i_fifo_rdat), 
    // Connect to memories
    .mem_we	(mem_w),
    .mem_a	(mem_a),
    .mem_d	(mem_d),
    .mem_q	(mem_q) 
    );
    //
  `ifdef ALTERA_FPGA 	
  
  sp_sram_16k36 inst_ram 
  (
    .address	(mem_a),
    .clock		(tc_clk),
    .data		(mem_d),
    .wren		(mem_w),
    .q			(mem_q) 
  );
  
  
 `else 
  sp_sram_16k36 inst_ram 
  (
    .clka	(tc_clk),
    .wea	(mem_w),
    .addra	(mem_a),
    .dina	(mem_d),
    .douta	(mem_q) 
  );
 `endif
//
endmodule 
