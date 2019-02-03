/*
 
  Department    : IC Design, FTDI SGP
  Author        : ElPrg
  History       : 25 April 2016 - Initial Version 

  Description   : This is the top module of Master FIFO bus  
*/

module ft601_x32_top

#
(
WIDTH_DATA   		= 32,
CNT_BE				= 4,

ADC_WIDTH_DATA		= 12
)

(

// Cyclone IV GX Dev Kit 150
input HRST_N, // SYS_RESETn

input MLTCN , //user_dipsw[0]
input STREN , //user_dipsw[1]
input ERDIS , //user_dipsw[2]


//FT601 Interface

input    				CLK		,
input 					SRST_N  ,

input 					WAKEUP_N,

inout  [WIDTH_DATA-1:0] DATA	,
inout  [CNT_BE-1:0] 	BE_N		,
input  					RXF_N	,    // ACK_N
input  					TXE_N	,

output 					WR_N	,    // REQ_N
output 					SIWU_N	, //
output 					RD_N	,
output 					OE_N	,

input 					R_OOB	,
input 					W_OOB	,

output [3-1:0] STRER,
output [3-1:0] debug_sig


);


// wire HRST_N;
// wire SRST_N;
// wire WAKEUP_N;

// wire MLTCN; 
// wire STREN; 
// wire ERDIS; 

// wire R_OOB; 
// wire W_OOB; 

// assign MLTCN = '1; //multi_chanell mode ON
// assign STREN = '1; // Streamtest
// assign ERDIS = '0; //enable check stream
 
 

// Miscellaneous Interface 
//wire [CNT_CHANNLS-1:0] debug_sig;
//wire [CNT_CHANNLS-1:0] STRER;


fifo_mst_top 
// #
// (
// )

inst_mst_fifo_ft60x_ctrl 
(

//GPIO Control Signals INPUTS
	.RESET_N(HRST_N)		, //Hard Reset
//	.SRST_N		, //Soft Reset
//	.MLTCN		, // 1: Multi Channel Mode		, 0: 245 Mode 
//	.STREN		, // 1: Streaming Test		,     0: Loopback Test
//	.ERDIS		, // 1: Disable received data sequence check  
//	.R_OOB		, //Read Out-Of-Band – 245 Mode Once asserted to high while TXE_N being low		, the master writes 1 byte then stops writing regardless of the state of TXE_N until R_OOB negates
//	.W_OOB		, //Write Out-Of-Band – 245 Mode Once asserted to high		, master reads and discards data as long as RXF_N is asserted. RXF_N may assert multiple times while W_OOB is asserted 
//	.WAKEUP_N	, //Suspend/Remote Wakeup pin by default Low when USB is active		, high when USB is in suspend. Application can drive this pin low in in USB suspend to generate a remote wakeup signal to the USB host.

// FIFO Slave interface (Phy_Interface) 
//INPUTS
	.CLK		,
	.DATA		,
	.BE(BE_N)	,
	.RXF_N		,    // ACK_N
	.TXE_N		,
	
//Outputs
	.WR_N		,   // REQ_N
	.SIWU_N		, 	//
	.RD_N		,
	.OE_N		,
// Miscellaneous Interface 
  // .debug_sig,
   .sys_led(STRER)

);

endmodule
