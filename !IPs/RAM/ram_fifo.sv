//RAMs _FIFO


/*

	//FIFO_OUT
			
			PCI_FIFO_OUT_CNT_WORDS = 256,//Размером слова для FIFO является WIDTH_WRITE_DATA, т.е. он задается стороной записи 
			PCI_FIFO_OUT_COEFF_OTNOSHENIYA = 4,
			PCI_FIFO_OUT_WIDTH_WRITE_DATA = 32,
			PCI_FIFO_OUT_WIDTH_READ_DATA = PCI_FIFO_OUT_WIDTH_WRITE_DATA*PCI_FIFO_OUT_COEFF_OTNOSHENIYA, //WIDTH_READ_DATA = 8и под него расчитывались размеры счетчиков
			PCI_FIFO_OUT_WRITE_CNT =  $clog2(PCI_FIFO_OUT_CNT_WORDS), // for this case = 10
				
			PCI_FIFO_OUT_READ_CNT = ( PCI_FIFO_OUT_WIDTH_WRITE_DATA > PCI_FIFO_OUT_WIDTH_READ_DATA ) ? PCI_FIFO_OUT_WRITE_CNT + $clog2(PCI_FIFO_OUT_COEFF_OTNOSHENIYA):  PCI_FIFO_OUT_WRITE_CNT - $clog2(PCI_FIFO_OUT_COEFF_OTNOSHENIYA),
			PCI_FIFO_OUT_WIDTH_DELAY_PIPE = 4,
			PCI_FIFO_OUT_THRESHOLD_RD  = 16	,//количество слов в фифо, которое необходимотоябы набралось, когда его можно читать
		
	//FIFO_IN
	
			PCI_FIFO_IN_CNT_WORDS = 64,//Размером слова для FIFO является WIDTH_WRITE_DATA, т.е. он задается стороной записи 
			PCI_FIFO_IN_COEFF_OTNOSHENIYA = 4,
			PCI_FIFO_IN_WIDTH_WRITE_DATA = 128,
			PCI_FIFO_IN_WIDTH_READ_DATA = PCI_FIFO_IN_WIDTH_WRITE_DATA/PCI_FIFO_IN_COEFF_OTNOSHENIYA, //WIDTH_READ_DATA = 8и под него расчитывались размеры счетчиков
			PCI_FIFO_IN_WRITE_CNT =  $clog2(PCI_FIFO_IN_CNT_WORDS), // for this case = 10 
			PCI_FIFO_IN_READ_CNT = ( PCI_FIFO_IN_WIDTH_WRITE_DATA > PCI_FIFO_IN_WIDTH_READ_DATA ) ? PCI_FIFO_IN_WRITE_CNT + $clog2(PCI_FIFO_IN_COEFF_OTNOSHENIYA):  PCI_FIFO_IN_WRITE_CNT - $clog2(PCI_FIFO_IN_COEFF_OTNOSHENIYA),
			PCI_FIFO_IN_WIDTH_DELAY_PIPE = 4,
			
			
			FIFO_OUT pci_FIFO_OUT 
(
	//.aclr(~rst_n|shift_fifo_out_cntrs_final),
	.aclr(~rst_n|clr_fifo_out),
	.data(pci_l_dato),
	.wrclk(clk), //IMPORT 
	.wrreq( fifo_out_wr_en),
	.wrfull(fifo_out_wr_full),
	.wrusedw(fifo_out_wr_cnt_words), 
	
	.rdclk(pci_fifo_in_clk),
	.rdreq(pci_fifo_out_rd_en|fifo_out_push_impl),
	.rdempty(fifo_out_rd_empty),
	.rdusedw(fifo_out_rd_cnt_words),
	.q(pci_fifo_out_rd_data)

);

defparam 		
		pci_FIFO_OUT.CNT_WORDS = PCI_FIFO_OUT_CNT_WORDS,
		pci_FIFO_OUT.WIDTH_WRITE_DATA = PCI_FIFO_OUT_WIDTH_WRITE_DATA,
		pci_FIFO_OUT.COEFF_OTNOSHENIYA = PCI_FIFO_OUT_COEFF_OTNOSHENIYA,
		pci_FIFO_OUT.WIDTH_DELAY_PIPE = PCI_FIFO_OUT_WIDTH_DELAY_PIPE;

*/

module rom 
#
(
parameter 
			
	CNT_WORDS = 1024,
	WIDTH_DATA = 32,			
	WIDTH_ADR =  $clog2(CNT_WORDS) ,// for this case = 10 
	
	FPGA_FAMILY = "Arria II GX"
	
			
)
(

	input	[WIDTH_ADR-1:0]  address,
	input	  clock,
	output	[WIDTH_DATA-1:0]  q
);
	
	wire [WIDTH_DATA-1:0] sub_wire0;
	assign q = sub_wire0[WIDTH_DATA-1:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.clock0 (clock),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_a (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_a (1'b0),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = "ram_dual.mif",
		altsyncram_component.intended_device_family = FPGA_FAMILY,
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 256,
		altsyncram_component.operation_mode = "ROM",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.widthad_a = 8,
		altsyncram_component.width_a = 8,
		altsyncram_component.width_byteena_a = 1;


endmodule

//--------------------------------------------------------------

module ram 

#
(
parameter 
			
	CNT_WORDS = 1024,
	WIDTH_DATA = 32,			
	WIDTH_ADR =  $clog2(CNT_WORDS) ,// for this case = 10 
	
	FPGA_FAMILY = "Arria II GX"
	
			
)

(

	input	[WIDTH_ADR-1:0]  address,
	input	  clock,
	input	[WIDTH_DATA-1:0]  data,
	input	  wren,
	output	[WIDTH_DATA-1:0]  q

);

	wire [WIDTH_DATA-1:0] sub_wire0;
	assign q = sub_wire0[WIDTH_DATA-1:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = "ram_dual.mif",
		altsyncram_component.intended_device_family = FPGA_FAMILY,
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = CNT_WORDS,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = WIDTH_ADR,
		altsyncram_component.width_a = WIDTH_DATA,
		altsyncram_component.width_byteena_a = 1;


endmodule

//-----------------------------------------------

module ram_dual

#
(
parameter 
			
	CNT_WORDS = 1024,
	WIDTH_DATA = 32,			
	WIDTH_ADR =  $clog2(CNT_WORDS) ,// for this case = 10 
	
	FPGA_FAMILY = "Arria II GX"
	
			
)
(
	
	input	[WIDTH_ADR-1:0]  address_a,
	input	[WIDTH_ADR-1:0]  address_b,
	input	clock_a,
	input	clock_b,
	input	[WIDTH_DATA-1:0]  data_a,
	input	[WIDTH_DATA-1:0]  data_b,
	input	wren_a,
	input	wren_b,
	input  	aclr_a,
	input 	aclr_b,
	
	output	[WIDTH_DATA-1:0]  q_a,
	output	[WIDTH_DATA-1:0]  q_b
	
	
/* `ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock_a,
	tri0	  wren_a,
	tri0	  wren_b,
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif */
);	

	wire [WIDTH_DATA-1:0] sub_wire0;
	wire [WIDTH_DATA-1:0] sub_wire1;
	assign q_a = sub_wire0[WIDTH_DATA-1:0];
	assign q_b = sub_wire1[WIDTH_DATA-1:0];

	altsyncram	altsyncram_component (
				.clock0 (clock_a),
				.wren_a (wren_a),
				.address_b (address_b),
				.clock1 (clock_b),
				.data_b (data_b),
				.wren_b (wren_b),
				.address_a (address_a),
				.data_a (data_a),
				.q_a (sub_wire0),
				.q_b (sub_wire1),
				.aclr0 (aclr_a),
				.aclr1 (aclr_b),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	defparam
		altsyncram_component.address_reg_b = "CLOCK1",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK1",
		altsyncram_component.intended_device_family = FPGA_FAMILY,
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = CNT_WORDS,
		altsyncram_component.numwords_b = CNT_WORDS,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "CLEAR0",
		altsyncram_component.outdata_aclr_b = "CLEAR1",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK1",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = WIDTH_ADR,
		altsyncram_component.widthad_b = WIDTH_ADR,
		altsyncram_component.width_a = WIDTH_DATA,
		altsyncram_component.width_b = WIDTH_DATA,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";


endmodule

	
module ram_dual_x2_clk 

#
(
parameter 
			
			CNT_WORDS = 1024,
			WIDTH_DATA = 32,			
			WIDTH_ADR =  $clog2(CNT_WORDS),// for this case = 10 
			
			FPGA_FAMILY = "Arria II GX"
			
)
(
	
	input	[WIDTH_ADR-1:0]  address_a,
	input	[WIDTH_ADR-1:0]  address_b,
	input	  clock_a,
	input	  clock_b,
	input	[WIDTH_DATA-1:0]  data_a,
	input	[WIDTH_DATA-1:0]  data_b,
	input	  wren_a,
	input	  wren_b,
	input  aclr_a,
	input aclr_b,
	
	output	[WIDTH_DATA-1:0]  q_a,
	output	[WIDTH_DATA-1:0]  q_b
	
	
/* `ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock_a,
	tri0	  wren_a,
	tri0	  wren_b,
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif */
);	

	wire [WIDTH_DATA-1:0] sub_wire0;
	wire [WIDTH_DATA-1:0] sub_wire1;
	assign q_a = sub_wire0[WIDTH_DATA-1:0];
	assign q_b = sub_wire1[WIDTH_DATA-1:0];

	altsyncram	altsyncram_component (
				.clock0 (clock_a),
				.wren_a (wren_a),
				.address_b (address_b),
				.clock1 (clock_b),
				.data_b (data_b),
				.wren_b (wren_b),
				.address_a (address_a),
				.data_a (data_a),
				.q_a (sub_wire0),
				.q_b (sub_wire1),
				.aclr0 (aclr_a),
				.aclr1 (aclr_b),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	defparam
		altsyncram_component.address_reg_b = "CLOCK1",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK1",
		altsyncram_component.intended_device_family = FPGA_FAMILY,
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = CNT_WORDS,
		altsyncram_component.numwords_b = CNT_WORDS,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "CLEAR0",
		altsyncram_component.outdata_aclr_b = "CLEAR1",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK1",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = WIDTH_ADR,
		altsyncram_component.widthad_b = WIDTH_ADR,
		altsyncram_component.width_a = WIDTH_DATA,
		altsyncram_component.width_b = WIDTH_DATA,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";


endmodule


//Module FIFO_OUT /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module fifo_out 
#
(

parameter 
			
			CNT_WORDS = 1024,//Размером слова для FIFO является WIDTH_WRITE_DATA, т.е. он задается стороной записи 
			COEFF_OTNOSHENIYA = 4,
			WIDTH_WRITE_DATA = 32,			
			WIDTH_READ_DATA = COEFF_OTNOSHENIYA*WIDTH_WRITE_DATA, //WIDTH_READ_DATA = 8и под него расчитывались размеры счетчиков
			WIDTH_WRITE_CNT =  $clog2(CNT_WORDS), // for this case = 10 
			WIDTH_READ_CNT = ( WIDTH_WRITE_DATA > WIDTH_READ_DATA ) ? WIDTH_WRITE_CNT + $clog2(COEFF_OTNOSHENIYA):  WIDTH_WRITE_CNT - $clog2(COEFF_OTNOSHENIYA), //14, //14
			WIDTH_DELAY_PIPE = 4 ,
			
			FPGA_FAMILY = "Arria II GX"
			 
			
)
(

	input	  aclr,
	input	[WIDTH_WRITE_DATA-1:0]  data,
	input	  rdclk,
	input	  rdreq,
	input	  wrclk,
	input	  wrreq,
	output	[WIDTH_READ_DATA-1:0]  q,
	output	  rdempty,
	output	[WIDTH_READ_CNT-1:0]  rdusedw,
	output	  wrfull,
	output	[WIDTH_WRITE_CNT-1:0]  wrusedw


//для параметров
//		dcfifo_mixed_widths_component.intended_device_family = "Arria II GX",
//		dcfifo_mixed_widths_component.lpm_numwords = 16384,
//		dcfifo_mixed_widths_component.lpm_showahead = "OFF",
//		dcfifo_mixed_widths_component.lpm_type = "dcfifo_mixed_widths",
//		dcfifo_mixed_widths_component.lpm_width = 32,
//		dcfifo_mixed_widths_component.lpm_widthu = 14,
//		dcfifo_mixed_widths_component.lpm_widthu_r = 12,
//		dcfifo_mixed_widths_component.lpm_width_r = 128,
//		dcfifo_mixed_widths_component.overflow_checking = "ON",
//		dcfifo_mixed_widths_component.rdsync_delaypipe = 5,
//		dcfifo_mixed_widths_component.read_aclr_synch = "ON",
//		dcfifo_mixed_widths_component.underflow_checking = "ON",
//		dcfifo_mixed_widths_component.use_eab = "ON",
//		dcfifo_mixed_widths_component.write_aclr_synch = "ON",
//		dcfifo_mixed_widths_component.wrsync_delaypipe = 5;


	
/* `ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  aclr
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif
 */
);


	wire  sub_wire0;
	wire [WIDTH_READ_DATA-1:0] sub_wire1;
	wire  sub_wire2;
	wire [WIDTH_WRITE_CNT-1:0] sub_wire3;
	wire [WIDTH_READ_CNT-1:0] sub_wire4;
	
	assign wrfull = sub_wire0;
	assign q = sub_wire1[WIDTH_READ_DATA-1:0];
	assign rdempty = sub_wire2;
	assign wrusedw = sub_wire3[WIDTH_WRITE_CNT-1:0];
	assign rdusedw = sub_wire4[WIDTH_READ_CNT-1:0];

	dcfifo_mixed_widths	dcfifo_mixed_widths_component (
				.rdclk (rdclk),
				.wrclk (wrclk),
				.wrreq (wrreq),
				.aclr (aclr),
				.data (data),
				.rdreq (rdreq),
				.wrfull (sub_wire0),
				.q (sub_wire1),
				.rdempty (sub_wire2),
				.wrusedw (sub_wire3),
				.rdusedw (sub_wire4),
				.rdfull (),
				.wrempty ());
	defparam
		dcfifo_mixed_widths_component.intended_device_family = FPGA_FAMILY ,
		dcfifo_mixed_widths_component.lpm_numwords = CNT_WORDS,
		dcfifo_mixed_widths_component.lpm_type = "dcfifo_mixed_widths",
		dcfifo_mixed_widths_component.lpm_width = WIDTH_WRITE_DATA,
		dcfifo_mixed_widths_component.lpm_widthu = WIDTH_WRITE_CNT,
		dcfifo_mixed_widths_component.lpm_widthu_r = WIDTH_READ_CNT,
		dcfifo_mixed_widths_component.lpm_width_r = WIDTH_READ_DATA,
		dcfifo_mixed_widths_component.overflow_checking = "OFF",
		dcfifo_mixed_widths_component.rdsync_delaypipe = WIDTH_DELAY_PIPE,
		dcfifo_mixed_widths_component.read_aclr_synch = "ON",
		dcfifo_mixed_widths_component.underflow_checking = "OFF",
		dcfifo_mixed_widths_component.use_eab = "ON",
		dcfifo_mixed_widths_component.write_aclr_synch = "OFF",
		dcfifo_mixed_widths_component.lpm_showahead = "OFF" , // Не включаем т.к. на вsходе по управлению записи данных ДДР стоит регистр pci_fifo_out_rd_en_rdy

   	dcfifo_mixed_widths_component.wrsync_delaypipe = WIDTH_DELAY_PIPE;

endmodule //FIFO_OUT


//
//
//Module fifo_IN /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module fifo_in
#
(
parameter 
			
			CNT_WORDS = 256,//Размером слова для FIFO является WIDTH_WRITE_DATA, т.е. он задается стороной записи 
			COEFF_OTNOSHENIYA = 4,
			WIDTH_WRITE_DATA = 128,
			WIDTH_READ_DATA = WIDTH_WRITE_DATA/COEFF_OTNOSHENIYA, //WIDTH_READ_DATA = 8и под него расчитывались размеры счетчиков
			WIDTH_WRITE_CNT =  $clog2(CNT_WORDS), // for this case = 8 
			WIDTH_READ_CNT = ( WIDTH_WRITE_DATA > WIDTH_READ_DATA ) ? WIDTH_WRITE_CNT + $clog2(COEFF_OTNOSHENIYA):  WIDTH_WRITE_CNT - $clog2(COEFF_OTNOSHENIYA), //10
			WIDTH_DELAY_PIPE = 4 ,

			FPGA_FAMILY = "Arria II GX"			
			
)

(
	input	  aclr,
	input	[WIDTH_WRITE_DATA-1:0]  data,
	input	  rdclk,
	input	  rdreq,
	input	  wrclk,
	input	  wrreq,
	output	[WIDTH_READ_DATA-1:0]  q,
	output	  rdempty,
	output	[WIDTH_READ_CNT-1:0]  rdusedw,
	output	  wrfull,
	output	[WIDTH_WRITE_CNT-1:0]  wrusedw

	
/* `ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif */

);


//EXAMPLE ( WIDTH_READ_DATA < WIDTH_WRITE_DATA ) ? $clog2(CNT_WORDS) :  $clog2(CNT_WORDS) + WIDTH_READ_DATA/WIDTH_WRITE_DATA //14
//		dcfifo_mixed_widths_component.intended_device_family = "Arria II GX",
//		dcfifo_mixed_widths_component.lpm_numwords = 1024,
//		dcfifo_mixed_widths_component.lpm_showahead = "OFF",
//		dcfifo_mixed_widths_component.lpm_type = "dcfifo_mixed_widths",
//		dcfifo_mixed_widths_component.lpm_width = 128,
//		dcfifo_mixed_widths_component.lpm_widthu = 10,
//		dcfifo_mixed_widths_component.lpm_widthu_r = 14,
//		dcfifo_mixed_widths_component.lpm_width_r = 8,
//		dcfifo_mixed_widths_component.overflow_checking = "ON",
//		dcfifo_mixed_widths_component.rdsync_delaypipe = 4,
//		dcfifo_mixed_widths_component.read_aclr_synch = "ON",
//		dcfifo_mixed_widths_component.underflow_checking = "ON",
//		dcfifo_mixed_widths_component.use_eab = "ON",
//		dcfifo_mixed_widths_component.write_aclr_synch = "ON",
//		dcfifo_mixed_widths_component.wrsync_delaypipe = 4;


			

	wire  sub_wire0;
	wire [WIDTH_READ_DATA-1:0] sub_wire1;
	wire  sub_wire2;
	wire [WIDTH_WRITE_CNT-1:0] sub_wire3;
	wire [WIDTH_READ_CNT-1:0] sub_wire4;
	
	assign  wrfull = sub_wire0;
	assign  q = sub_wire1[WIDTH_READ_DATA-1:0];
	assign rdempty = sub_wire2;
	assign wrusedw = sub_wire3[WIDTH_WRITE_CNT-1:0];
	assign rdusedw = sub_wire4[WIDTH_READ_CNT-1:0];

	dcfifo_mixed_widths	dcfifo_mixed_widths_component (
				.rdclk (rdclk),
				.wrclk (wrclk),
				.wrreq (wrreq),
				.aclr (aclr),
				.data (data),
				.rdreq (rdreq),
				.wrfull (sub_wire0),
				.q (sub_wire1),
				.rdempty (sub_wire2),
				.wrusedw (sub_wire3),
				.rdusedw (sub_wire4),
				.rdfull (),
				.wrempty ());
	defparam
		dcfifo_mixed_widths_component.intended_device_family = FPGA_FAMILY ,
		dcfifo_mixed_widths_component.lpm_numwords = CNT_WORDS,
		dcfifo_mixed_widths_component.lpm_type = "dcfifo_mixed_widths",
		dcfifo_mixed_widths_component.lpm_width = WIDTH_WRITE_DATA,
		dcfifo_mixed_widths_component.lpm_widthu = WIDTH_WRITE_CNT,
		dcfifo_mixed_widths_component.lpm_widthu_r = WIDTH_READ_CNT,
		dcfifo_mixed_widths_component.lpm_width_r = WIDTH_READ_DATA,
		dcfifo_mixed_widths_component.overflow_checking = "OFF",
		dcfifo_mixed_widths_component.rdsync_delaypipe = WIDTH_DELAY_PIPE,
		dcfifo_mixed_widths_component.read_aclr_synch = "ON",
		dcfifo_mixed_widths_component.underflow_checking = "OFF",
		dcfifo_mixed_widths_component.use_eab = "ON",
		dcfifo_mixed_widths_component.write_aclr_synch = "ON",
		
		dcfifo_mixed_widths_component.lpm_showahead = "OFF" ,
		dcfifo_mixed_widths_component.wrsync_delaypipe = WIDTH_DELAY_PIPE;
		
		


endmodule //FIFO_IN


//Module fifo_test /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//module fifo_pci_test_integrated (
//	data,
//	rdclk,
//	rdreq,
//	wrclk,
//	wrreq,
//	q,
//	rdempty,
//	wrfull);
//
//	
//	parameter 
//			
//			CNT_WORDS = 1024,//Размером слова для FIFO является WIDTH_WRITE_DATA, т.е. он задается стороной записи 
//			WIDTH_WRITE_DATA = 32,
//			WIDTH_READ_DATA = 32, //WIDTH_READ_DATA = 8и под него расчитывались размеры счетчиков
//			WIDTH_WRITE_CNT =  $clog2(CNT_WORDS), // for this case = 10 
//			WIDTH_READ_CNT = ( WIDTH_WRITE_DATA > WIDTH_WRITE_DATA ) ? WIDTH_WRITE_CNT + $clog2(WIDTH_READ_DATA/WIDTH_WRITE_DATA):  WIDTH_WRITE_CNT - $clog2(WIDTH_READ_DATA/WIDTH_WRITE_DATA), //14
//			WIDTH_DELAY_PIPE = 3 
//			 
//			;
//	
//	input	[WIDTH_WRITE_DATA-1:0]  data;
//	input	  rdclk;
//	input	  rdreq;
//	input	  wrclk;
//	input	  wrreq;
//	output	[WIDTH_READ_DATA-1:0]  q;
//	output	  rdempty;
//	output	  wrfull;
//
//	wire  sub_wire0;
//	wire [WIDTH_READ_DATA-1:0] sub_wire1;
//	wire  sub_wire2;
//	wire  wrfull = sub_wire0;
//	wire [WIDTH_READ_DATA-1:0] q = sub_wire1[WIDTH_READ_DATA-1:0];
//	wire  rdempty = sub_wire2;
//
//	
//	
//	
//	dcfifo	dcfifo_component (
//				.data (data),
//				.rdclk (rdclk),
//				.rdreq (rdreq),
//				.wrclk (wrclk),
//				.wrreq (wrreq),
//				.wrfull (sub_wire0),
//				.q (sub_wire1),
//				.rdempty (sub_wire2),
//				.aclr (),
//				.rdfull (),
//				.rdusedw (),
//				.wrempty (),
//				.wrusedw ());
//	defparam
//		dcfifo_component.intended_device_family = "Arria II GX",
//		dcfifo_component.lpm_numwords = 1024,
//		dcfifo_component.lpm_showahead = "ON",
//		dcfifo_component.lpm_type = "dcfifo",
//		dcfifo_component.lpm_width = 32,
//		dcfifo_component.lpm_widthu = 10,
//		dcfifo_component.overflow_checking = "ON",
//		dcfifo_component.rdsync_delaypipe = 3,
//		dcfifo_component.underflow_checking = "ON",
//		dcfifo_component.use_eab = "ON",
//		dcfifo_component.wrsync_delaypipe = 3;
//
//
//endmodule


