//------------------------------------------------------------------------------
// Title        : fifo_mst_top.v 
// Project      : FT600
//------------------------------------------------------------------------------
// Author       : Wai Kwok 
// Date Created : 22th Mar,2014
//		changed	: me_2019_01_22 	
//------------------------------------------------------------------------------
// Description  : 
//                FT600 FIFO Master TOP 
//
//
//------------------------------------------------------------------------------
// Known issues & omissions:
// 
// 
//------------------------------------------------------------------------------
// Copyright 2013 FTDI Ltd. All rights reserved.
//------------------------------------------------------------------------------
import pkg_ft601_ctrl_defines::*;

module fifo_mst_top (
  // TO/FROM pads
  // system control
  input                RESET_N,

  // FIFO interface 
  input                		CLK,
  inout [WIDTH_DATA-1:0]    DATA,
  inout [CNT_BE-1:0]        BE,
  input                RXF_N,   // ACK_N
  input                TXE_N,
  output               WR_N,    // REQ_N
  output               SIWU_N,
  output               RD_N,
  output               OE_N,

  // misc interface
  // outputs
  output wire          debug_sig,   
`ifdef VX6
  output wire [7:0]    sys_led
`else
  output wire [CNT_BE-1:0]    sys_led
`endif
);


  wire                 i_mode;
  wire                 grant;
  wire                 idle_st;
  wire                 m_rd_wr;
  wire                 snd_cmd;
  wire                 mem_rdy;
  wire [$clog2(CNT_CHANNLS):0]           t_ep_num;
  wire [CNT_BE-1:0]           bus_cmd;
  wire [WIDTH_DATA-1:0]          tx_data;
  wire [WIDTH_DATA-1:0]          rx_data;
  wire [CNT_BE-1:0]           rx_be;
  wire                 rx_rxf_n;
  wire                 rx_txe_n;
  wire                 mem_wren;
  wire                 mem_rden;
  wire                 mem_cs;
  wire [CNT_BE-1:0]           all_m_wr_be;
  wire [CNT_BE-1:0]           m_wr_be[CNT_CHANNLS];
  // wire [CNT_BE-1:0]           m_wr_be_2;
  // wire [CNT_BE-1:0]           m_wr_be_3;
  // wire [CNT_BE-1:0]           m_wr_be_4;
  
  wire [T_MSZ-1:0]     all_ram_adr;
  wire [T_MSZ-1:0]     ram_adr[CNT_CHANNLS];
  // wire [T_MSZ-1:0]     ram_adr_2;
  // wire [T_MSZ-1:0]     ram_adr_3;
  // wire [T_MSZ-1:0]     ram_adr_4;
  wire                 fifo_empty_all;
  wire                 fifo_full_all;
  
  wire                 [CNT_CHANNLS-1:0] fifo_empty;
  // wire                 fifo_empty_2;
  // wire                 fifo_empty_3;
  // wire                 fifo_empty_4;
  
  wire                 [CNT_CHANNLS-1:0] fifo_full;
  // wire                 fifo_full_2;
  // wire                 fifo_full_3;
  // wire                 fifo_full_4;
  
  wire                 ld_2_empty_all;
  
  wire                 ld_2_empty[CNT_CHANNLS];
  // wire                 ld_2_empty_2;
  // wire                 ld_2_empty_3;
  // wire                 ld_2_empty_4;
  
  wire                 ld_2_full_all;
  
  wire                 ld_2_full[CNT_CHANNLS];
  // wire                 ld_2_full_2;
  // wire                 ld_2_full_3;
  // wire                 ld_2_full_4;
  
  wire [WIDTH_BUS_STATUS-1:0]   slv_status;
  wire                 			u_rd_ptr;
  wire [EPm_MSZ:0]     			c_rd_ptr;
  wire [EPm_MSZ:0]     			all_ep_rd_ptr;
  
  wire [EPm_MSZ:0]     			ep_rd_ptr[CNT_CHANNLS];
  // wire [EP2_MSZ:0]     ep_rd_ptr_2;
  // wire [EP3_MSZ:0]     ep_rd_ptr_3;
  // wire [EP4_MSZ:0]     ep_rd_ptr_4;
  
  wire                 		fifoClk;
  wire                 		dly_rstn;
  wire                 		tm_rstn;
  wire                 		tc_chipRstn;
  wire [WIDTH_DATA-1:0]     tc_data;
  wire [CNT_BE-1:0]         tc_be;
  wire                  	tc_rxf_n;
  wire                  	tc_txe_n;
  wire [WIDTH_DATA-1:0] 	tp_data;
  wire [CNT_BE-1:0]     	tp_be;
  wire                  	tp_wr_n;
  wire                  	tp_dt_oe_n;
  wire                  	tp_be_oe_n;

  
  
  //EXAMPLE localparam array
    // localparam bit [7:0] [ADDR_BITS-1:0] ADDR_OFFSET = ADDR_CALC();
   // function bit [7:0] [ADDR_BITS-1:0] ADDR_CALC();
      // for(int ii=0;ii<$size(ADDR_CALC,1); ii++)
    // ADDR_CALC[ii] = ii * PAGE_SIZE;
   // endfunction 
  
  `define def_EPm_MSZ 10 
  
  localparam logic [EPm_MSZ-1:0] [CNT_CHANNLS : 1] EP_BASE_ADR 
  
  = 
  {
  `def_EPm_MSZ'h0   ,
  `def_EPm_MSZ'h400 ,
  `def_EPm_MSZ'h800 ,
  `def_EPm_MSZ'hc00 
  
  };

   // EP_BASE_ADR[1] = 'h0   ;
  	// EP_BASE_ADR[2] = 'h400 ;
  	// EP_BASE_ADR[3] = 'h800 ;
  	// EP_BASE_ADR[4] = 'hc00 ;
 

///////////////////////////////////////////////////////////////////////////////
// system LEDs 
//

 logic [7:0] ind ;

 always_comb
 begin
 
 	for(ind = 0; ind < 4; ind ++)
	begin 

		  sys_led[ind] = fifo_empty[ind] & tm_rstn; // indicate EP1 buffer is empty
		  // sys_led[1] = fifo_empty_2 & tm_rstn; // indicate EP2 buffer is empty
		  // sys_led[2] = fifo_empty_3 & tm_rstn; // indicate EP3 buffer is empty
		  // sys_led[3] = fifo_empty_4 & tm_rstn; // indicate EP4 buffer is empty

	`ifdef VX6

		sys_led[ind+4] = fifo_full[ind] & tm_rstn;  // indicate EP1 buffer is full
//		sys_led[4+5] = fifo_full_2 & tm_rstn;  // indicate EP2 buffer is full
//		sys_led[4+6] = fifo_full_3 & tm_rstn;  // indicate EP3 buffer is full
//		sys_led[4+7] = fifo_full_4 & tm_rstn;  // indicate EP4 buffer is full

	`endif
	
	end	// for(ind = 0; ind < 4; ind ++)
	
end

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Debug signals
//
//
  assign debug_sig = rx_txe_n;
  assign i_mode = 1'b0;
///////////////////////////////////////////////////////////////////////////////

  assign tm_rstn  = tc_chipRstn & dly_rstn;
  
  // assign fifo_empty_all = (fifo_empty_1 & (t_ep_num == EP1_NUM)) |
                          // (fifo_empty_2 & (t_ep_num == EP2_NUM)) |
                          // (fifo_empty_3 & (t_ep_num == 3'b011)) |
                          // (fifo_empty_4 & (t_ep_num == 3'b100));

  // assign fifo_full_all = (fifo_full_1 & (t_ep_num == 3'b001)) |
                         // (fifo_full_2 & (t_ep_num == 3'b010)) |
                         // (fifo_full_3 & (t_ep_num == 3'b011)) |
                         // (fifo_full_4 & (t_ep_num == 3'b100));

  // assign ld_2_empty_all = ld_2_empty_1 | ld_2_empty_2 |
                          // ld_2_empty_3 | ld_2_empty_4;

 
  // assign ld_2_full_all = ld_2_full_1 | ld_2_full_2 |
                         // ld_2_full_3 | ld_2_full_4;
 
  
logic [CNT_CHANNLS-1:0] ep_rd_ptr_Transponir [EPm_MSZ+1] ;
logic [CNT_CHANNLS-1:0] m_wr_be_Transponir 	[CNT_BE];
logic [CNT_CHANNLS-1:0] ram_adr_Transponir 	[T_MSZ];

logic [CNT_CHANNLS-1:0] fifo_empty_Transponir;
logic [CNT_CHANNLS-1:0] fifo_full_Transponir;
logic [CNT_CHANNLS-1:0] ld_2_empty_Transponir;
logic [CNT_CHANNLS-1:0] ld_2_full_Transponir;



//function  !!! Nado podumati kak eto zagnati parametricheskuu funkciu
logic [7:0 ] ind_2; 
always_comb
begin


	//START ------------------Transponnir---------------------------	
	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin  
		
		for(ind_2 = 0; ind_2 < EPm_MSZ+1; ind_2 ++)
		begin 
			ep_rd_ptr_Transponir[ind_2][ind] = ep_rd_ptr[ind][ind_2];
		end
		
		for(ind_2 = 0; ind_2 < CNT_BE; ind_2 ++)
		begin 	
			m_wr_be_Transponir[ind_2][ind] 	= m_wr_be[ind][ind_2];
		end
		
		for(ind_2 = 0; ind_2 < T_MSZ; ind_2 ++)
		begin
			ram_adr_Transponir[ind_2][ind] 	= ram_adr[ind][ind_2];
		end
	
	
	fifo_empty_Transponir[ind] =  (fifo_empty[ind] & (t_ep_num == (EP1_NUM + ind))) ;
	  // (fifo_empty_2 & (t_ep_num == EP2_NUM)) |
	  // (fifo_empty_3 & (t_ep_num == 3'b011)) |
	  // (fifo_empty_4 & (t_ep_num == 3'b100));

	fifo_full_Transponir[ind] = (fifo_full[ind] & (t_ep_num == (EP1_NUM + ind))) ;
	// fifo_full_all = (fifo_full_1 & (t_ep_num == 3'b001)) |
	// (fifo_full_2 & (t_ep_num == 3'b010)) |
	// (fifo_full_3 & (t_ep_num == 3'b011)) |
	// (fifo_full_4 & (t_ep_num == 3'b100));

	
	ld_2_empty_Transponir[ind] = ld_2_empty[ind];
	
	ld_2_full_Transponir[ind] = ld_2_full[ind] ;
	
	
	// ld_2_empty_all = ld_2_empty_1 | ld_2_empty_2 |
	 // ld_2_empty_3 | ld_2_empty_4;

	// ld_2_full_all = ld_2_full_1 | ld_2_full_2 |
		   // ld_2_full_3 | ld_2_full_4;	

		   
	end// for(ind = 0; ind < CNT_CHANNLS; ind ++) Transponir
  
  //END ------------------Transponnir---------------------------	

  //START ------------------Set Resulted---------------------------
	for(ind = 0; ind < EPm_MSZ+1; ind ++)
	begin 
  		all_ep_rd_ptr[ind]  = |ep_rd_ptr_Transponir[ind];
	end
	
    for(ind = 0; ind < CNT_BE; ind ++)
	begin 	
		all_m_wr_be[ind] 	= |m_wr_be_Transponir[ind];
	end
	
	for(ind = 0; ind < T_MSZ; ind ++)
	begin
		all_ram_adr[ind] 	= |ram_adr_Transponir[ind];
	end
		
			
			
	fifo_empty_all = |fifo_empty_Transponir;
	  // (fifo_empty_2 & (t_ep_num == EP2_NUM)) |
	  // (fifo_empty_3 & (t_ep_num == 3'b011)) |
	  // (fifo_empty_4 & (t_ep_num == 3'b100));

	fifo_full_all = |fifo_full_Transponir;
	// fifo_full_all = (fifo_full_1 & (t_ep_num == 3'b001)) |
	// (fifo_full_2 & (t_ep_num == 3'b010)) |
	// (fifo_full_3 & (t_ep_num == 3'b011)) |
	// (fifo_full_4 & (t_ep_num == 3'b100));

	
	ld_2_empty_all = |ld_2_empty_Transponir;
	
	ld_2_full_all = |ld_2_full_Transponir;

	//END ------------------Set Resulted---------------------------	
end						 
						 
						 
  assign slv_status = rx_data[STAUS_IND_END:STAUS_IND_START];


///////////////////////////////////////////////////////////////////////////////
// instantiations 

  fifo_mst_dpath i_fifo_mst_dpath (
    // inputs
    .fifoRstn(tm_rstn),
    .fifoClk(fifoClk),
    .tc_data(tc_data),
    .tc_be(tc_be),
    .tc_txe_n(tc_txe_n),
    .tc_rxf_n(tc_rxf_n),
    .snd_cmd(snd_cmd),
    .bus_cmd(bus_cmd),
    .tx_data(tx_data),
    .tx_be(all_m_wr_be),
    .ep_num(t_ep_num),
    // outputs 
    .tp_data(tp_data),
    .tp_be(tp_be),
    .rx_txe_n(rx_txe_n),
    .rx_rxf_n(rx_rxf_n),
    .rx_data(rx_data),
    .rx_be(rx_be)
  );


  fifo_mst_arb i_fifo_mst_arb (
    // inputs
    .fifoRstn(tm_rstn),
    .fifoClk(fifoClk),
    .idle_st(idle_st),
    .slv_f_st_n(slv_status),
    .mst_f_st_n({fifo_full[CNT_CHANNLS-1:0], fifo_empty[CNT_CHANNLS-1:0]}),
    .mem_rdy(mem_rdy),
    // outputs
    .grant(grant),
    .t_ep_num(t_ep_num),
    .m_rd_wr(m_rd_wr)
  );


  fifo_mst_fsm #(
    .EPm_MSZ(EPm_MSZ)
    ) i_fifo_mst_fsm (
    // inputs
    .rstn(tm_rstn),
    .clk(fifoClk),
    .tc_rxf_n(rx_rxf_n),
    .grant(grant),
    .m_rd_wr(m_rd_wr),
    .fifo_full(fifo_full_all),
    .fifo_empty(fifo_empty_all),
    .ld_2_full(ld_2_full_all),
    .ld_2_empty(ld_2_empty_all),
    .ep_rd_ptr(all_ep_rd_ptr),
    // outputs 
    .idle_st(idle_st),
    .cmd_out(bus_cmd),
    .tp_wr_n(tp_wr_n),
    .snd_cmd(snd_cmd),
    .tp_dt_oe_n(tp_dt_oe_n),
    .tp_be_oe_n(tp_be_oe_n),
    .u_rd_ptr(u_rd_ptr),
    .c_rd_ptr(c_rd_ptr),
    .mem_cs(mem_cs),
    .mem_wren(mem_wren),
    .mem_rden(mem_rden)
  );

  fifo_mst_ram #(
    .T_MSZ(T_MSZ)
    ) i_fifo_mst_ram (
    // inputs
    .rstn(tm_rstn),
    .clk(fifoClk),
    .wr_en({4{mem_wren}} & rx_be),
    .mem_en(mem_cs),
    .mem_addr(all_ram_adr),
    .mem_din(rx_data),
    // outputs
    .mem_rdy(mem_rdy),
    .mem_do(tx_data)
    );

	
// fifo_ep_mst - GEN_VARS

genvar ind_chnl;

generate
for(ind_chnl = 0; ind_chnl < CNT_CHANNLS; ind_chnl++ ) 
begin : fifo_ep_mst_inst 

  fifo_ep_mst #(
    .EP_NUM(ind_chnl+1),
    .EP_BASE_ADR(EP_BASE_ADR[ind_chnl+1]),
    .T_MSZ(T_MSZ),
    .EPm_MSZ(EPm_MSZ),
    .EP_MSZ(EPm_MSZ)
    ) i_fifo_ep_mst (
                // inputs
                .fifoRstn(tm_rstn),
                .fifoClk(fifoClk),
                .i_mode(i_mode),
                .m_wr_en(mem_rden),
                .m_rd_en(mem_wren),
                .m_rd_be(rx_be),
                .ep_num(t_ep_num),
                .m_wr_sel(~m_rd_wr),
                .u_rd_ptr(u_rd_ptr),
                .c_rd_ptr(c_rd_ptr),
                // outputs
                .m_wr_be(m_wr_be[ind_chnl]),
                .ram_adr(ram_adr[ind_chnl]),
                .ep_rd_ptr(ep_rd_ptr[ind_chnl]),
                .fifo_empty(fifo_empty[ind_chnl]),
                .fifo_full(fifo_full[ind_chnl]),
                .ld_2_empty(ld_2_empty[ind_chnl]),
                .ld_2_full(ld_2_full[ind_chnl])
    );

end	

endgenerate
	
  // fifo_ep_mst #(
    // .EP_NUM(EP2_NUM),
    // .EP_BASE_ADR(EP2_BASE_ADR),
    // .T_MSZ(T_MSZ),
    // .EPm_MSZ(EPm_MSZ),
    // .EP_MSZ(EP2_MSZ)
    // ) i_fifo_ep_mst_2 (
                // // inputs
                // .fifoRstn(tm_rstn),
                // .fifoClk(fifoClk),
                // .i_mode(i_mode),
                // .m_wr_en(mem_rden),
                // .m_rd_en(mem_wren),
                // .m_rd_be(rx_be),
                // .ep_num(t_ep_num),
                // .m_wr_sel(~m_rd_wr),
                // .u_rd_ptr(u_rd_ptr),
                // .c_rd_ptr(c_rd_ptr),
                // // outputs
                // .m_wr_be(m_wr_be_2),
                // .ram_adr(ram_adr_2),
                // .ep_rd_ptr(ep_rd_ptr_2),
                // .fifo_empty(fifo_empty_2),
                // .fifo_full(fifo_full_2),
                // .ld_2_empty(ld_2_empty_2),
                // .ld_2_full(ld_2_full_2)
    // );

  // fifo_ep_mst #(
    // .EP_NUM(EP3_NUM),
    // .EP_BASE_ADR(EP3_BASE_ADR),
    // .T_MSZ(T_MSZ),
    // .EPm_MSZ(EPm_MSZ),
    // .EP_MSZ(EP3_MSZ)
    // ) i_fifo_ep_mst_3 (
                // // inputs
                // .fifoRstn(tm_rstn),
                // .fifoClk(fifoClk),
                // .i_mode(i_mode),
                // .m_wr_en(mem_rden),
                // .m_rd_en(mem_wren),
                // .m_rd_be(rx_be),
                // .ep_num(t_ep_num),
                // .m_wr_sel(~m_rd_wr),
                // .u_rd_ptr(u_rd_ptr),
                // .c_rd_ptr(c_rd_ptr),
                // // outputs
                // .m_wr_be(m_wr_be_3),
                // .ram_adr(ram_adr_3),
                // .ep_rd_ptr(ep_rd_ptr_3),
                // .fifo_empty(fifo_empty_3),
                // .fifo_full(fifo_full_3),
                // .ld_2_empty(ld_2_empty_3),
                // .ld_2_full(ld_2_full_3)
    // );

  // fifo_ep_mst #(
    // .EP_NUM(EP4_NUM),
    // .EP_BASE_ADR(EP4_BASE_ADR),
    // .T_MSZ(T_MSZ),
    // .EPm_MSZ(EPm_MSZ),
    // .EP_MSZ(EP4_MSZ)
    // ) i_fifo_ep_mst_4 (
                // // inputs
                // .fifoRstn(tm_rstn),
                // .fifoClk(fifoClk),
                // .i_mode(i_mode),
                // .m_wr_en(mem_rden),
                // .m_rd_en(mem_wren),
                // .m_rd_be(rx_be),
                // .ep_num(t_ep_num),
                // .m_wr_sel(~m_rd_wr),
                // .u_rd_ptr(u_rd_ptr),
                // .c_rd_ptr(c_rd_ptr),
                // // outputs
                // .m_wr_be(m_wr_be_4),
                // .ram_adr(ram_adr_4),
                // .ep_rd_ptr(ep_rd_ptr_4),
                // .fifo_empty(fifo_empty_4),
                // .fifo_full(fifo_full_4),
                // .ld_2_empty(ld_2_empty_4),
                // .ld_2_full(ld_2_full_4)
    // );

  fifo_mst_io i_fifo_mst_io (
             // to/from PADS 
             .RESET_N(RESET_N),
             .CLK(CLK),
             .DATA(DATA),
             .BE(BE),
             .TXE_N(TXE_N),
             .RXF_N(RXF_N),
             .SIWU_N(SIWU_N),
             .WR_N(WR_N),
             .RD_N(RD_N),
             .OE_N(OE_N),

             // inputs
             .tp_dt_oe_n(tp_dt_oe_n),
             .tp_be_oe_n(tp_be_oe_n),
             .tp_data(tp_data),
             .tp_be(tp_be),
             .tp_siwu_n(1'b1),
             .tp_wr_n(tp_wr_n),
             .tp_rd_n(1'b1),
             .tp_oe_n(1'b1),

             // outputs
             .tc_chipRstn(tc_chipRstn),
             .tc_clk(fifoClk),
             .tc_data(tc_data),
             .tc_be(tc_be),
             .tc_txe_n(tc_txe_n),
             .tc_rxf_n(tc_rxf_n)
            );

  timer_cntr #(.NUM_BIT(3),
               .INI_ST(3'b111)
              ) i_startup_timer (
  // inputs
    .rstn(tc_chipRstn),
    .clk(fifoClk),
    .enable(1'b1),
    .load(1'b0),
    .count(3'b000),
  // outputs
    .reach_zero(dly_rstn)

  );


endmodule
