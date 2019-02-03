
import pkg_adc_defines::*;

module adc_ctrl
// #
// (
// WIDTH_DATA   		= 32,

// ADC_WIDTH_DATA_IN	= 12
// )
(
  input rst_n ,
  
  //ADC_Data
  
 input [ADC_WIDTH_DATA_IN -1: 0]	adc_phy_d,
 input 								adc_phy_clk_out, 
  
 // output [ADC_WIDTH_DATA_DESER_OUT-1:0] 	loc_adc_data_out,
 // output 							loc_adc_clk_out

 //FIFO
 input 									adc_fifo_clk_rd,
 input 									adc_fifo_en_rd,
 //pci_rd_req_data
 
 output [ADC_WIDTH_DATA_FIFO_OUT-1:0] 	loc_adc_data_fifo_out,
 
 output 								adc_fifo_wr_full,
 output									adc_fifo_rd_empty,
 
 output									adc_fifo_rd_rdy
 
 
);


//Iputs Alies assigns
assign fifo_in_rd_req 			= adc_fifo_en_rd ;
//Outputs Alies assigns
assign adc_fifo_wr_full 		= fifo_in_wr_full ;
assign adc_fifo_rd_empty		= fifo_in_rd_empty;
assign loc_adc_data_fifo_out 	= fifo_in_data_out;

//Deserializing LVDS 12 to 96 , koeff = 8
//

logic [ADC_WIDTH_DATA_DESER_OUT-1:0] 	loc_adc_data_out;
logic 									loc_adc_clk_out;

lvds_rx
#
(
.CHANNELS_NUM 			( ADC_WIDTH_DATA_IN),
.DESERIALIZATION_FACTOR	( ADC_DESERIALIZATION_FACTOR)
)
inst_lvds_rx
(
//input
.rx_in			(adc_phy_d)         , // 12 bit
.rx_inclock		(adc_phy_clk_out)   , // 250 Mhz

//ouput
.rx_out     	(loc_adc_data_out)  , // 96 bit
.rx_outclock	(loc_adc_clk_out)     // 250 Mhz/koeff = 31.5 Mhz             
	
);

/////////////////////////////////////////////////////////////////////////
//START: FIFO_IN logic
/////////////////////////////////////////////////////////////////////////

wire  fifo_in_wr_en;
wire [ADC_FIFO_IN_WRITE_CNT-1:0] fifo_in_wr_cnt_words;
wire  fifo_in_wr_full;
wire [ADC_FIFO_IN_READ_CNT-1:0] fifo_in_rd_cnt_words;

wire fifo_in_rd_empty;
wire [ADC_FIFO_IN_WIDTH_READ_DATA-1:0] fifo_in_data_out;
reg  fifo_in_rd_req ;


reg [ADC_FIFO_IN_WRITE_CNT-1:0] cnt_wrds_pump_read_ddr ;

reg fifo_in_rd_pci_trans, pci_fifo_in_rd_trans;
// fifo_in_rd_pci_trans - строб разрешения записи из ДДр3 в ФИФО_IN
//pci_fifo_in_rd_trans - передача из  FIFO_IN в PCI
wire fifo_in_push_impl;


//assign loc_adc_data_fifo_out = 
// т.к. у FIFO_OUT выключен параметр lpm_showahead слеовательно чтобы выставить первое слово на выход надо сделать на +1 чтание больше
// , для этого fifo_out_push_impl

wire adc_fifo_in_wr_en = 1'b1;

fifo_in 
#
(
.CNT_WORDS 			( ADC_FIFO_IN_CNT_WORDS			),
.COEFF_OTNOSHENIYA 	( ADC_FIFO_IN_WIDTH_WRITE_DATA	),
.WIDTH_WRITE_DATA 	( ADC_FIFO_IN_COEFF_OTNOSHENIYA	),
.WIDTH_DELAY_PIPE 	( ADC_FIFO_IN_WIDTH_DELAY_PIPE	)

)
inst_adc_fifo_in
(

	.aclr	(~rst_n|impl_clr_fifo_in), // происходит сброс счетчиков в 0

//WR
	.wrclk	( loc_adc_clk_out		),
	
	.data	( loc_adc_data_out		),
	
	.wrreq	( adc_fifo_in_wr_en		),
	.wrfull	( fifo_in_wr_full		),
	.wrusedw( fifo_in_wr_cnt_words	), 

//RD	
	.rdclk	(	adc_fifo_clk_rd),
	.rdreq	(	fifo_in_rd_req | fifo_in_push_impl),
	.rdempty(	fifo_in_rd_empty),
	.rdusedw(	fifo_in_rd_cnt_words),
	
	.q		(	fifo_in_data_out)

);


///*

//FIFO_IN_WR CTRL_DDR_RD--------------------------------------
//Цикл записи данных из ADC в FIFO_IN

reg impl_clr_fifo_in;


always @(posedge adc_fifo_clk_rd or negedge rst_n)//ddr clk
begin

if( !rst_n)
begin

adc_fifo_rd_rdy 		<= '0;
fifo_in_rd_pci_trans 	<= '0;
pci_fifo_in_rd_trans 	<= '0;

impl_clr_fifo_in <= '0;

end
else
begin

impl_clr_fifo_in <= '0;
	
	
	if( fifo_in_rd_cnt_words == VALUE_CNT_FIFO_IN_REDY_FOR_READ-1  )//конец DDR3 to FIFO_IN начало FIFO_IN to PCI
	begin

		adc_fifo_rd_rdy <= 1;
		
	end
	
	if( adc_fifo_rd_rdy == 1 && fifo_in_rd_cnt_words == VALUE_CNT_FIFO_IN_END )
	begin
	
		adc_fifo_rd_rdy  <= 0;
		impl_clr_fifo_in <= 1;
		
	end
	
	
end//else !rstn	
	
end//always

//*/



endmodule