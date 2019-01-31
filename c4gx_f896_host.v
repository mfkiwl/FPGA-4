//--------------------------------------------------------------------------//
// Title:       c4gx_f896_host.v                                            //
// Rev:         Rev 1                                                     //
// Created:     November 29, 2010 		                                     //
// Author:		 Altera High Speed Design Group - San Diego            		 //
//--------------------------------------------------------------------------//
// Description: Golden Top design contains all pins and I/O standards for   //
//              the Cyclone IV GX FPGA Development Board.                   //
//--------------------------------------------------------------------------//
// Revision History:                                                        //
// Rev 1:                                              //
//----------------------------------------------------------------------------
//------ 1 ------- 2 ------- 3 ------- 4 ------- 5 ------- 6 ------- 7 ------7
//------ 0 ------- 0 ------- 0 ------- 0 ------- 0 ------- 0 ------- 0 ------8
//----------------------------------------------------------------------------
//Copyright © 2010 Altera Corporation. All rights reserved.  Altera products  
//are protected under numerous U.S. and foreign patents, maskwork rights,     
//copyrights and other intellectual property laws.                            
//                                                                            
//Your use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.                           
//                                                                            
//This reference design file, and your use thereof, is subject to and         
//governed by the terms and conditions of the applicable Altera Reference     
//Design License Agreement.  By using this reference design file, you         
//indicate your acceptance of such terms and conditions between you and       
//Altera Corporation.  In the event that you do not agree with such terms and 
//conditions, you may not use the reference design file. Please promptly      
//destroy any copies you have made.                                           
//                                                                            
//This reference design file being provided on an "as-is" basis and as an     
//accommodation and therefore all warranties, representations or guarantees   
//of any kind (whether express, implied or statutory) including, without      
//limitation, warranties of merchantability, non-infringement, or fitness for 
//a particular purpose, are specifically disclaimed.  By making this          
//reference design file available, Altera expressly does not recommend,       
//suggest or require that this reference design file be used in combination   
//with any other product not provided by Altera.                              
//  

                                                                        
//`define	hsma_xcvrs
`define	hsma_parallel_x41
//`define	hsmb_xcvrs
`define	hsmb_parallel_x41
//`define	pcie_xcvrs
//`define	hsma_lvds


`ifdef	hsma_xcvrs          
	`define	use_clkin_100m_p_1  
	`define	hsma_xcvrs_refclk_p 	clkin_100m_p_1
`endif   

`ifdef	hsmb_xcvrs          
	`define	use_clkin_100m_p_1  
	`define	hsmb_xcvrs_refclk_p	clkin_100m_p_1
`endif   
 
`ifdef	pcie_xcvrs     
	`define	use_pcie_refclk_p
	`define	pcie_xcvrs_refclk_p	pcie_refclk_p
`endif

`ifdef	hsma_lvds 
	//`define	use_clkin_125m_p  
	//`define	hsma_lvds_refclk_p	clkin_125m_p
	`define	use_clkin_100m_p_1  
	`define	hsma_lvds_refclk_p 	clkin_100m_p_1	
`else
	// Allow 125 MHz clock to exist in design
	`define	use_clkin_125m_p  
`endif 

module c4gx_f896_host (
//--------------Clocks------------------
	input          clkin_50,             //2.5V    //Bank 8B  
`ifdef	use_clkin_100m_p_0
	input    clkin_100m_p_0,         //LVDS    // 
`endif 
`ifdef	use_clkin_100m_p_1
	input    clkin_100m_p_1,         //LVDS    // 
`endif 

`ifdef	use_clkin_125m_p
	input          clkin_125m_p,         //LVDS    // 
`endif
	input          clkin_sma,            //1.8V    //
	output         clkout_sma,           //1.8V    //

//--------------User-IO-----------------
	input          sys_resetn,           //2.5V    //TR=0, DEV_CLRn
	input          cpu_resetn,           //1.8V    //TR=0
	input  [7:0]   user_dipsw,           //1.8V    //TR=0
	output [7:0]   user_led,             //1.8V
	input  [3:0]   user_pb,              //1.8V    //TR=0

//-------------DDR2-Port-A--------------//1.8V    //Banks 3&4
	output [12:0]  ddr2a_a,              //SSTL18  
	output [1:0]   ddr2a_ba,             //SSTL18
	inout  [31:0]  ddr2a_dq,             //SSTL18
	inout  [3:0]   ddr2a_dqs,            //SSTL18
	output [3:0]   ddr2a_dm,             //SSTL18
	output         ddr2a_wen,            //SSTL18
	output         ddr2a_rasn,           //SSTL18
	output         ddr2a_casn,           //SSTL18
	inout          ddr2a_clk_p,          //SSTL18
	inout          ddr2a_clk_n,          //SSTL18
	output         ddr2a_cke,            //SSTL18
	output         ddr2a_csn,            //SSTL18
	output         ddr2a_odt,            //SSTL18

//-------------DDR2-Port-A--------------//1.8V    //Banks 7&8
	output [12:0]  ddr2b_a,              //SSTL18  
	output [1:0]   ddr2b_ba,             //SSTL18  
	inout  [31:0]  ddr2b_dq,             //SSTL18  
	inout  [3:0]   ddr2b_dqs,            //SSTL18  
	output [3:0]   ddr2b_dm,             //SSTL18  
	output         ddr2b_wen,            //SSTL18  
	output         ddr2b_rasn,           //SSTL18  
	output         ddr2b_casn,           //SSTL18  
	inout          ddr2b_clk_p,          //SSTL18  
	inout          ddr2b_clk_n,          //SSTL18  
	output         ddr2b_cke,            //SSTL18  
	output         ddr2b_csn,            //SSTL18  
	output         ddr2b_odt,            //SSTL18  

//------------SSRAM-Control-------------//1.8V    //Banks 7&8
	output			ssram_clk,            //1.8V
	output			ssram_e1n,            //1.8V    //Chip enable
	output			ssram_ban,            //1.8V    //Byte Enable
	output			ssram_bbn,            //1.8V    //Byte Enable
	output			ssram_bwn,            //1.8V
//	output			ssram_gwn,            //1.8V
//	output			ssram_adscn,          //1.8V
//	output			ssram_adspn,          //1.8V
//	output			ssram_advn,           //1.8V    //Addr valid
	output			ssram_gn,             //1.8V    //Output enable

//------------Flash-Control-------------//1.8V    //Banks 7&8
	output			flash_advn,           //1.8V
	output			flash_cen,            //1.8V
	output			flash_clk,            //1.8V
	output			flash_oen,            //1.8V
	input          flash_rdybsyn,        //1.8V
	output			flash_resetn,         //1.8V    //TR=0
	output			flash_wen,            //1.8V

//----------------FSM-Bus---------------//1.8V    
   output [25:1]  fsm_a,                //
   inout  [15:0]  fsm_d,                //

//---------------Ethernet--------------//        //Bank 8
	output [3:0]   enet_tx_d,           //1.8V    //Trans to 2.5V
   output         enet_gtx_clk,        //1.8V    //Trans to 2.5V
	output         enet_tx_en,          //1.8V    //Trans to 2.5V
	input  [3:0]   enet_rx_d,           //1.8V    //Trans to 2.5V ???
	input          enet_rx_clk,         //1.8V    //Trans to 2.5V ???
	input          enet_rx_dv,          //1.8V    //Trans to 2.5V ???
   input          enet_intn,           //1.8V    //Trans to 2.5V       //TR=0
   output         enet_mdc,            //1.8V    //Trans to 2.5V       //TR=0
   inout          enet_mdio,           //1.8V    //Trans to 2.5V       //TR=0
   output         enet_resetn,         //1.8V    //Trans to 2.5V       //TR=0

//-------------PCI Express--------------//        //Bank QL0 w/HIP    
`ifdef	use_pcie_refclk_p		
	input          pcie_refclk_p,      //HCSL
`endif
`ifdef	pcie_xcvrs
	output [3:0]   pcie_tx_p,            //2.5V PCML
	input  [3:0]   pcie_rx_p,            //2.5V PCML
`endif
	input          pcie_smbclk,          //1.8V      //TR=0
   inout          pcie_smbdat,          //1.8V      //TR=0
   input          pcie_perstn,          //1.8V      //TR=0
   output         pcie_led_x1,          //1.8V      //TR=0
   output         pcie_led_x4,          //1.8V      //TR=0

//-------------HSMC-Port-A--------------//2.5V      //Banks 
`ifdef	hsma_xcvrs
   output   [3:0]    hsma_tx_p,         //2.5V PCML
   input    [3:0]    hsma_rx_p,         //2.5V PCML
`endif
`ifdef	hsma_parallel_x41  
	input	hsma_in_d_1	,
	input	hsma_in_d_3	,
	input	hsma_in_d_5     ,
	input	hsma_in_d_7     ,
	input	hsma_in_d_9     ,
	input	hsma_in_d_11    ,
	input	hsma_in_d_13    ,
	input	hsma_in_d_15    ,
	input	hsma_in_d_17    ,
	input	hsma_in_d_19    ,
	input	hsma_in_d_21    ,
	input	hsma_in_d_23    ,
	input	hsma_in_d_25    ,
	input	hsma_in_d_27    ,
	input	hsma_in_d_29    ,
	input	hsma_in_d_31    ,
	input	hsma_in_d_33    ,
	input	hsma_in_d_35    ,
	input	hsma_in_d_37    ,
	input	hsma_in_d_39    ,
	input	hsma_in_d_41    ,
	input	hsma_in_d_43    ,
	input	hsma_in_d_45    ,
	input	hsma_in_d_47    ,
	input	hsma_in_d_49    ,
	input	hsma_in_d_51    ,
	input	hsma_in_d_53    ,
	input	hsma_in_d_55    ,
	input	hsma_in_d_57    ,
	input	hsma_in_d_59    ,
	input	hsma_in_d_61    ,
	input	hsma_in_d_63    ,
	input	hsma_in_d_65    ,
	input	hsma_in_d_67    ,
	input	hsma_in_d_69    ,
	input	hsma_in_d_71    ,
	input	hsma_in_d_73    ,
	input	hsma_in_d_75    ,
	input	hsma_in_d_77    ,
	input	hsma_in_d_79    ,
	output	hsma_out_d_0    ,
	output	hsma_out_d_2    ,
	output	hsma_out_d_4    ,
	output	hsma_out_d_6    ,
	output	hsma_out_d_8    ,
	output	hsma_out_d_10   ,
	output	hsma_out_d_12   ,
	output	hsma_out_d_14   ,
	output	hsma_out_d_16   ,
	output	hsma_out_d_18   ,
	output	hsma_out_d_20   ,
	output	hsma_out_d_22   ,
	output	hsma_out_d_24   ,
	output	hsma_out_d_26   ,
	output	hsma_out_d_28   ,
	output	hsma_out_d_30   ,
	output	hsma_out_d_32   ,
	output	hsma_out_d_34   ,
	output	hsma_out_d_36   ,
	output	hsma_out_d_38   ,
	output	hsma_out_d_40   ,
	output	hsma_out_d_42   ,
	output	hsma_out_d_44   ,
	output	hsma_out_d_46   ,
	output	hsma_out_d_48   ,
	output	hsma_out_d_50   ,
	output	hsma_out_d_52   ,
	output	hsma_out_d_54   ,
	output	hsma_out_d_56   ,
	output	hsma_out_d_58   ,
	output	hsma_out_d_60   ,
	output	hsma_out_d_62   ,
	output	hsma_out_d_64   ,
	output	hsma_out_d_66   ,
	output	hsma_out_d_68   ,
	output	hsma_out_d_70   ,
	output	hsma_out_d_72   ,
	output	hsma_out_d_74   ,
	output	hsma_out_d_76   ,
	output	hsma_out_d_78   ,
	input   hsma_clk_in0,      //1.8V      //input only
	output	hsma_clk_out0,     //2.5V      //output only
//	inout					hsma_sda,          //1.8V      //TR=0
	input					hsma_sda,          //Make input for loopback test
	output				hsma_scl,          //2.5V      //TR=0	
`endif
`ifdef	hsma_lvds
	output	[16:0]	hsma_tx_d_p,       //LVDS      //
	input		[16:0]	hsma_rx_d_p,       //LVDS      //
	input		[2:1]		hsma_clk_in_p,     //LVDS
	output	[2:1]		hsma_clk_out_p,    //LVDS
`endif
`ifdef	hsma_parallel_x3
	//inout		[3:0]		hsma_d,            //2.5V      //Bank
	input	hsma_in_d_1	,
	input	hsma_in_d_3	,
	input	hsma_out_d_0	,
	input	hsma_out_d_2	,
   input             hsma_clk_in0,      //1.8V      //input only
	output				hsma_clk_out0,     //2.5V      //output only
//	inout					hsma_sda,          //1.8V      //TR=0
	input					hsma_sda,          //Make input for loopback test
	output				hsma_scl,          //2.5V      //TR=0	
`endif
	output				hsma_tx_led,       //1.8V
	output				hsma_rx_led,       //1.8V
	input					hsma_prsntn,       //1.8V      //TR=0
	
//-------------HSMC-Port-B--------------//2.5+1.8V //Banks 
`ifdef	hsmb_xcvrs
   output [3:0]      hsmb_tx_p,         //2.5V PCML //Requires resistor mux change 
   input  [3:0]      hsmb_rx_p,         //2.5V PCML //Requires resistor mux change
`endif
`ifdef	hsmb_parallel_x41
	input	hsmb_in_d_1	,
	input	hsmb_in_d_3	,
	input	hsmb_in_d_5     ,
	input	hsmb_in_d_7     ,
	input	hsmb_in_d_9     ,
	input	hsmb_in_d_11    ,
	input	hsmb_in_d_13    ,
	input	hsmb_in_d_15    ,
	input	hsmb_in_d_17    ,
	input	hsmb_in_d_19    ,
	input	hsmb_in_d_21    ,
	input	hsmb_in_d_23    ,
	input	hsmb_in_d_25    ,
	input	hsmb_in_d_27    ,
	input	hsmb_in_d_29    ,
	input	hsmb_in_d_31    ,
	input	hsmb_in_d_33    ,
	input	hsmb_in_d_35    ,
	input	hsmb_in_d_37    ,
	input	hsmb_in_d_39    ,
	input	hsmb_in_d_41    ,
	input	hsmb_in_d_43    ,
	input	hsmb_in_d_45    ,
	input	hsmb_in_d_47    ,
	input	hsmb_in_d_49    ,
	input	hsmb_in_d_51    ,
	input	hsmb_in_d_53    ,
	input	hsmb_in_d_55    ,
	input	hsmb_in_d_57    ,
	input	hsmb_in_d_59    ,
	input	hsmb_in_d_61    ,
	input	hsmb_in_d_63    ,
	input	hsmb_in_d_65    ,
	input	hsmb_in_d_67    ,
	input	hsmb_in_d_69    ,
	input	hsmb_in_d_71    ,
	input	hsmb_in_d_73    ,
	input	hsmb_in_d_75    ,
	input	hsmb_in_d_77    ,
	input	hsmb_in_d_79    ,
	output	hsmb_out_d_0    ,
	output	hsmb_out_d_2    ,
	output	hsmb_out_d_4    ,
	output	hsmb_out_d_6    ,
	output	hsmb_out_d_8    ,
	output	hsmb_out_d_10   ,
	output	hsmb_out_d_12   ,
	output	hsmb_out_d_14   ,
	output	hsmb_out_d_16   ,
	output	hsmb_out_d_18   ,
	output	hsmb_out_d_20   ,
	output	hsmb_out_d_22   ,
	output	hsmb_out_d_24   ,
	output	hsmb_out_d_26   ,
	output	hsmb_out_d_28   ,
	output	hsmb_out_d_30   ,
	output	hsmb_out_d_32   ,
	output	hsmb_out_d_34   ,
	output	hsmb_out_d_36   ,
	output	hsmb_out_d_38   ,
	output	hsmb_out_d_40   ,
	output	hsmb_out_d_42   ,
	output	hsmb_out_d_44   ,
	output	hsmb_out_d_46   ,
	output	hsmb_out_d_48   ,
	output	hsmb_out_d_50   ,
	output	hsmb_out_d_52   ,
	output	hsmb_out_d_54   ,
	output	hsmb_out_d_56   ,
	output	hsmb_out_d_58   ,
	output	hsmb_out_d_60   ,
	output	hsmb_out_d_62   ,
	output	hsmb_out_d_64   ,
	output	hsmb_out_d_66   ,
	output	hsmb_out_d_68   ,
	output	hsmb_out_d_70   ,
	output	hsmb_out_d_72   ,
	output	hsmb_out_d_74   ,
	output	hsmb_out_d_76   ,
	output	hsmb_out_d_78   ,
	input   hsmb_clk_in0,      //1.8V      //input only
	output	hsmb_clk_out0,     //2.5V      //output only
   //inout             hsmb_sda,          //1.8V     //TR=0
   input             hsmb_sda,          //Make input for loopback test
	output            hsmb_scl,          //1.8V     //TR=0
`endif
// HSMB LVDS unused due to board translators.
// This provides HSMB parallel I/O daughtercard compatibility
`ifdef	hsmb_lvds
 	output [16:0]      hsmb_tx_d_p,      //2.5V     //Bank 5
	output [16:0]      hsmb_tx_d_n,      //2.5V     //
   input  [16:0]      hsmb_rx_d_p,      //2.5V     //Bank 5
	input  [16:0]      hsmb_rx_d_n,      //2.5V     //
   input	 [2:1]      hsmb_clk_in_p,     //2=1.8V/1=2.5V
   input	 [2:1]      hsmb_clk_in_n,     //2=1.8V/1=2.5V
   output [2:1]      hsmb_clk_out_p,    //2=1.8V/1=2.5V
   output [2:1]      hsmb_clk_out_n,    //2=1.8V/1=2.5V
`endif
`ifdef	hsmb_parallel_x3
   // inout  [3:0]      hsmb_d,            //2.5V     //Bank 5
	input	hsmb_in_d_1	,
	input	hsmb_in_d_3	,
	input	hsmb_out_d_0	,
	input	hsmb_out_d_2	,
   input             hsmb_clk_in0,      //1.8V     //input only
   output            hsmb_clk_out0,     //2.5V
   //inout             hsmb_sda,          //1.8V     //TR=0
   input             hsmb_sda,          //Make input for loopback test
	output            hsmb_scl,          //1.8V     //TR=0
`endif
   output            hsmb_tx_led,       //1.8V
   output            hsmb_rx_led,       //1.8V
   input             hsmb_prsntn,       //1.8V     //TR=0
	
//-----------lcd-----------
	output			lcd_csn,
	output			lcd_d_cn,
	inout	[7:0]	   lcd_data, 
	output			lcd_wen,


//-----------max-----------
	output			max_csn,
	output			max_oen,
	output			max_wen,

	//TEMPRESERVE
	input ncso,
	input init_done
	
	
	/*
//-----------rup---------------
	input			rup2, //  Pin AD24      
//	input			rup3, //  Pin AD25
	input			rup4, //  Pin G25
	
//-----------rdn----------------
	input			rdn2, //  -- Pin AE24
//	input			rdn3, //  -- Pin AD26
	input			rdn4, //  -- Pin F25

*/

);   

		  wire	[40:0]	hsma_parallel_x41_rx_p;
        wire	[40:0]	hsma_parallel_x41_tx_p;  
        wire	[40:0]	hsmb_parallel_x41_rx_p;
        wire	[40:0]	hsmb_parallel_x41_tx_p;  
`ifdef	hsma_parallel_x41  
	assign	hsma_parallel_x41_rx_p	=
		{     
			hsma_in_d_1	,
			hsma_in_d_3	,
			hsma_in_d_5     ,
			hsma_in_d_7     ,
			hsma_in_d_9     ,
			hsma_in_d_11    ,
			hsma_in_d_13    ,
			hsma_in_d_15    ,
			hsma_in_d_17    ,
			hsma_in_d_19    ,
			hsma_in_d_21    ,
			hsma_in_d_23    ,
			hsma_in_d_25    ,
			hsma_in_d_27    ,
			hsma_in_d_29    ,
			hsma_in_d_31    ,
			hsma_in_d_33    ,
			hsma_in_d_35    ,
			hsma_in_d_37    ,
			hsma_in_d_39    ,
			hsma_in_d_41    ,
			hsma_in_d_43    ,
			hsma_in_d_45    ,
			hsma_in_d_47    ,
			hsma_in_d_49    ,
			hsma_in_d_51    ,
			hsma_in_d_53    ,
			hsma_in_d_55    ,
			hsma_in_d_57    ,
			hsma_in_d_59    ,
			hsma_in_d_61    ,
			hsma_in_d_63    ,
			hsma_in_d_65    ,
			hsma_in_d_67    ,
			hsma_in_d_69    ,
			hsma_in_d_71    ,
			hsma_in_d_73    ,
			hsma_in_d_75    ,
			hsma_in_d_77    ,
			hsma_in_d_79    ,
			hsma_sda
		};
			
		assign
		{     			
			hsma_out_d_0    ,
			hsma_out_d_2    ,
			hsma_out_d_4    ,
			hsma_out_d_6    ,
			hsma_out_d_8    ,
			hsma_out_d_10   ,
			hsma_out_d_12   ,
			hsma_out_d_14   ,
			hsma_out_d_16   ,
			hsma_out_d_18   ,
			hsma_out_d_20   ,
			hsma_out_d_22   ,
			hsma_out_d_24   ,
			hsma_out_d_26   ,
			hsma_out_d_28   ,
			hsma_out_d_30   ,
			hsma_out_d_32   ,
			hsma_out_d_34   ,
			hsma_out_d_36   ,
			hsma_out_d_38   ,
			hsma_out_d_40   ,
			hsma_out_d_42   ,
			hsma_out_d_44   ,
			hsma_out_d_46   ,
			hsma_out_d_48   ,
			hsma_out_d_50   ,
			hsma_out_d_52   ,
			hsma_out_d_54   ,
			hsma_out_d_56   ,
			hsma_out_d_58   ,
			hsma_out_d_60   ,
			hsma_out_d_62   ,
			hsma_out_d_64   ,
			hsma_out_d_66   ,
			hsma_out_d_68   ,
			hsma_out_d_70   ,
			hsma_out_d_72   ,
			hsma_out_d_74   ,
			hsma_out_d_76   ,
			hsma_out_d_78   ,
			hsma_scl
		}	=	 hsma_parallel_x41_tx_p;  
 
`endif                           

`ifdef	hsmb_parallel_x41  
	assign	hsmb_parallel_x41_rx_p	=
		{     
			hsmb_in_d_1	,
			hsmb_in_d_3	,
			hsmb_in_d_5     ,
			hsmb_in_d_7     ,
			hsmb_in_d_9     ,
			hsmb_in_d_11    ,
			hsmb_in_d_13    ,
			hsmb_in_d_15    ,
			hsmb_in_d_17    ,
			hsmb_in_d_19    ,
			hsmb_in_d_21    ,
			hsmb_in_d_23    ,
			hsmb_in_d_25    ,
			hsmb_in_d_27    ,
			hsmb_in_d_29    ,
			hsmb_in_d_31    ,
			hsmb_in_d_33    ,
			hsmb_in_d_35    ,
			hsmb_in_d_37    ,
			hsmb_in_d_39    ,
			hsmb_in_d_41    ,
			hsmb_in_d_43    ,
			hsmb_in_d_45    ,
			hsmb_in_d_47    ,
			hsmb_in_d_49    ,
			hsmb_in_d_51    ,
			hsmb_in_d_53    ,
			hsmb_in_d_55    ,
			hsmb_in_d_57    ,
			hsmb_in_d_59    ,
			hsmb_in_d_61    ,
			hsmb_in_d_63    ,
			hsmb_in_d_65    ,
			hsmb_in_d_67    ,
			hsmb_in_d_69    ,
			hsmb_in_d_71    ,
			hsmb_in_d_73    ,
			hsmb_in_d_75    ,
			hsmb_in_d_77    ,
			hsmb_in_d_79    ,
			hsmb_sda
		};
			
		assign
		{     			
			hsmb_out_d_0    ,
			hsmb_out_d_2    ,
			hsmb_out_d_4    ,
			hsmb_out_d_6    ,
			hsmb_out_d_8    ,
			hsmb_out_d_10   ,
			hsmb_out_d_12   ,
			hsmb_out_d_14   ,
			hsmb_out_d_16   ,
			hsmb_out_d_18   ,
			hsmb_out_d_20   ,
			hsmb_out_d_22   ,
			hsmb_out_d_24   ,
			hsmb_out_d_26   ,
			hsmb_out_d_28   ,
			hsmb_out_d_30   ,
			hsmb_out_d_32   ,
			hsmb_out_d_34   ,
			hsmb_out_d_36   ,
			hsmb_out_d_38   ,
			hsmb_out_d_40   ,
			hsmb_out_d_42   ,
			hsmb_out_d_44   ,
			hsmb_out_d_46   ,
			hsmb_out_d_48   ,
			hsmb_out_d_50   ,
			hsmb_out_d_52   ,
			hsmb_out_d_54   ,
			hsmb_out_d_56   ,
			hsmb_out_d_58   ,
			hsmb_out_d_60   ,
			hsmb_out_d_62   ,
			hsmb_out_d_64   ,
			hsmb_out_d_66   ,
			hsmb_out_d_68   ,
			hsmb_out_d_70   ,
			hsmb_out_d_72   ,
			hsmb_out_d_74   ,
			hsmb_out_d_76   ,
			hsmb_out_d_78   ,
			hsmb_scl
		}	=	 hsmb_parallel_x41_tx_p;  
`endif 
	
	

endmodule
