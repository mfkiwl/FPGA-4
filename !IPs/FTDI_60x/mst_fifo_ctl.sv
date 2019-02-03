/*
  File Name     : mst_fifo_ctl.v 
  Department    : IC Design, FTDI SGP
  Author        : Do Ngoc Duong
  History       : 25 April 2016 - Initial Version 

  Description   : This module controls internal FIFOs read/write operation 
                  It is written for specific case of master FIFO loopback 
*/

module mst_fifo_ctl 
#
(
WIDTH_DATA   		= 32,
WIDTH_PREF_DATA 	= 36,
CNT_BE				= 4,
CNT_CHANNLS 		= 4,
CNT_CODE_NUM_CHNLS	= $clog2(CNT_CHANNLS) , // = 2,

WIDTH_MEM_ADR 		= 14

)

( 
  input  clk,
  input  rst_n,
  input  mltcn, 
  //FIFO control 
  input  								fifo_rd,    
  input  [CNT_CODE_NUM_CHNLS-1:0] 		fifo_rd_id, 
  
  input  								fifo_wr,
  input  [CNT_CODE_NUM_CHNLS-1:0] 		fifo_wr_id,     
  //
  output reg 	[CNT_CHANNLS-1:0] 		fifo_afull, // high when fifo is almost full
  output wire 	[CNT_CHANNLS-1:0] 		fifo_nempt, // high when fifo is not empty
  //
  input  		[WIDTH_PREF_DATA-1:0] 	fifo_din,
  output wire 	[WIDTH_PREF_DATA-1:0] 	fifo_dout, 
 // Connect to memories
  output  wire mem_we,          // enable to write memories
  output  wire [WIDTH_MEM_ADR-1:0] 		mem_a,    // address of memories
  output  wire [WIDTH_PREF_DATA-1:0] 	mem_d,	// Data in 
  input   wire [WIDTH_PREF_DATA-1:0] 	mem_q	// Data out 
  );
////////////////////////////////////////////////////////////////////////////////
// Local logic and instantiation
wire mem_re;
reg [WIDTH_MEM_ADR-1:0] wr_cnt0;
reg [WIDTH_MEM_ADR-1-2:0] wr_cnt[1:3];
reg [WIDTH_MEM_ADR-1-2:0] wr_cnt_result;
// 
reg [WIDTH_MEM_ADR-1:0] rd_cnt0;
reg [WIDTH_MEM_ADR-1-2:0] rd_cnt[1:3];
reg [WIDTH_MEM_ADR-1-2:0] rd_cnt_result;
//
wire [WIDTH_MEM_ADR-1:0] mem_wa;
assign      mem_wa = mltcn ? {fifo_wr_id,wr_cnt_result} : wr_cnt0;
wire [WIDTH_MEM_ADR-1:0] mem_ra;
assign      mem_ra = mltcn ? {fifo_rd_id,rd_cnt_result} : rd_cnt0;
//

integer ind;



// always @ (*)  
  // begin 
  // case (fifo_wr_id)
    // 2'b00: wr_cnt_result = wr_cnt0[11:0];
    // 2'b01: wr_cnt_result = wr_cnt1;
    // 2'b10: wr_cnt_result = wr_cnt2;
    // 2'b11: wr_cnt_result = wr_cnt3;
  // endcase
  // end  
// //
// always @ (*)  
  // begin 
  // case (fifo_rd_id)
    // 2'b00: rd_cnt_result = rd_cnt0[11:0];
    // 2'b01: rd_cnt_result = rd_cnt1;
    // 2'b10: rd_cnt_result = rd_cnt2;
    // 2'b11: rd_cnt_result = rd_cnt3;
  // endcase
  // end 
 
always_comb
begin



	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin
		
		if( ind == 0)
		begin
			 wr_cnt_result = wr_cnt0[WIDTH_MEM_ADR-3:0];// obrezaem do WIDTH_MEM_ADR-1
			 rd_cnt_result = rd_cnt0[WIDTH_MEM_ADR-3:0];
		end
		else
		begin
			wr_cnt_result  = wr_cnt[ind];
			rd_cnt_result  = rd_cnt[ind];
		end
		
	
	end
	
end
 
assign mem_a = mem_we ? mem_wa : mem_ra;
assign mem_d = fifo_din;
assign fifo_dout = mem_q; 


//Write address counter

//Read address counter 

always @(posedge clk or negedge rst_n)
begin

		if(!rst_n)
		begin
		
			wr_cnt0 	<= '0; 			
			
		end
		else if (mem_we & (fifo_wr_id == 2'b00))
		begin
		
			wr_cnt0 <= wr_cnt0 + 1'b1;
		end

		if(!rst_n)
		begin
		
			rd_cnt0 	<= '0; 
			
			
		end
		else if (mem_we & (fifo_rd_id == 2'b00))
		begin
		
			rd_cnt0 <= rd_cnt0 + 1'b1;
		end		
	
	for(ind = 1; ind < CNT_CHANNLS; ind ++)
	begin	

		if(!rst_n)
		begin
			wr_cnt[ind] <= '0;   
		end
		else if (mem_we & (fifo_wr_id == ind)) 
		begin
			wr_cnt[ind] <= wr_cnt[ind] + 1'b1;
		end
		
		if(!rst_n)
		begin
			rd_cnt[ind] <= '0;   
		end
		else if (mem_we & (fifo_rd_id == ind)) 
		begin
			rd_cnt[ind] <= rd_cnt[ind] + 1'b1;
		end
	
	end
	
end	
  
  
  
//FIFO full
wire [CNT_CHANNLS-1:0] fifo_full;
wire 	full;
assign 	full  	  	=   fifo_full[fifo_wr_id];
// 
wire 	notempty;
assign 	notempty    =   fifo_nempt[fifo_rd_id];
//                  
assign mem_we       =   fifo_wr & (!full);
assign mem_re       =   fifo_rd & (notempty);
//
reg [WIDTH_MEM_ADR:0] fifo_len0;

reg [WIDTH_MEM_ADR-2:0] fifo_len[1:3];
// reg [FIFO_LEN-1:0] fifo_len1;
// reg [FIFO_LEN-1:0] fifo_len2;
// reg [FIFO_LEN-1:0] fifo_len3;
//

//FIFO not empty

// assign fifo_nempt[0] = |fifo_len0;
// assign fifo_nempt[1] = |fifo_len1;
// assign fifo_nempt[2] = |fifo_len2;
// assign fifo_nempt[3] = |fifo_len3; 
// // 
// assign fifo_full[0] = mltcn ? fifo_len0[12] : fifo_len0[14];
// assign fifo_full[1] = mltcn ? fifo_len1[12] : 1'b0;
// assign fifo_full[2] = mltcn ? fifo_len2[12] : 1'b0; 
// assign fifo_full[3] = mltcn ? fifo_len3[12] : 1'b0; 

always_comb
begin



	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin
	
		if(ind == 0) 
		begin
			fifo_nempt[ind] 	= |fifo_len0;
			fifo_full[ind] 		= mltcn ? fifo_len0[12] : fifo_len0[14];
		end
		else
		begin
		
			fifo_nempt[ind] = |fifo_len[ind];
			fifo_full[ind] = mltcn ? fifo_len[ind][12] : 1'b0;

		end
	end
end//always


always @ (posedge clk or negedge rst_n)
begin 
		
		if (!rst_n) 
		begin
		  fifo_len0 <= 15'h0000;
		end
		
		else if (mem_we & (fifo_wr_id == 2'b00))
		begin
		  fifo_len0 <= fifo_len0 + 1'b1;
		end
		else if (mem_re & (fifo_rd_id == 2'b00))
		begin
		  fifo_len0 <= fifo_len0 - 1'b1;
		end
	  
	


	for(ind = 1; ind < CNT_CHANNLS; ind ++)
	begin
	
	    if (!rst_n) 
		begin
			fifo_len[ind] <= 13'h0000;
		end
//>>> ind	 
			else if (mem_we & (fifo_wr_id == 2'b01))
			begin
				
				if (ind > 0)
				begin
					fifo_len[ind] <= fifo_len[ind] + 1'b1;
				end
			end
			else if (mem_re & (fifo_rd_id == 2'b01))
			begin
				if (ind > 0)
				begin	
					fifo_len[ind] <= fifo_len[ind] - 1'b1;
				end
			end
		
	end //for(ind = 0; ind < CNT_CHANNLS; ind ++)

	
	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin
		
		if (!rst_n)
		begin
		  fifo_afull[ind] <= '0;
		end
		else if (mltcn) 
		begin
			  
			if( ind == 0)
			begin
				fifo_afull[0] <= (fifo_len0 >= 15'h0FFB);
			end
			else
			begin
				fifo_afull[ind] <= (fifo_len[ind] >= 13'h0FFB);
			end
			
				

		end
		else  
		begin
			
			if( ind == 0)
			begin
				fifo_afull[0] <= (fifo_len0 >= 15'h3FFB);
			end
			else
			begin
				
				fifo_afull[ind] <= '0;
			
			end

		end
		
		
	end//for(ind = 0; ind < CNT_CHANNLS; ind ++) 	
		

		
				
end //always
	

	
	
// FIFO length 
// always @ (posedge clk or negedge rst_n)
  // begin 
    // if (!rst_n) 
      // fifo_len0 <= 15'h0000;
    // else if (mem_we & (fifo_wr_id == 2'b00))
      // fifo_len0 <= fifo_len0 + 1'b1;
    // else if (mem_re & (fifo_rd_id == 2'b00))
      // fifo_len0 <= fifo_len0 - 1'b1;
  // end 
// //
// always @ (posedge clk or negedge rst_n)
  // begin 
    // if (!rst_n) 
      // fifo_len1 <= 13'h0000;
    // else if (mem_we & (fifo_wr_id == 2'b01))
      // fifo_len1 <= fifo_len1 + 1'b1;
    // else if (mem_re & (fifo_rd_id == 2'b01))
      // fifo_len1 <= fifo_len1 - 1'b1;
  // end 
// //
// always @ (posedge clk or negedge rst_n)
  // begin 
    // if (!rst_n) 
      // fifo_len2 <= 13'h0000;
    // else if (mem_we & (fifo_wr_id == 2'b10))
      // fifo_len2 <= fifo_len2 + 1'b1;
    // else if (mem_re & (fifo_rd_id == 2'b10))
      // fifo_len2 <= fifo_len2 - 1'b1;
  // end 
// //
// always @ (posedge clk or negedge rst_n)
  // begin 
    // if (!rst_n) 
      // fifo_len3 <= 13'h0000;
    // else if (mem_we & (fifo_wr_id == 2'b11))
      // fifo_len3 <= fifo_len3 + 1'b1;
    // else if (mem_re & (fifo_rd_id == 2'b11))
      // fifo_len3 <= fifo_len3 - 1'b1;
  // end 
  
  
//FIFO Almost Full 
// always @ (posedge clk or negedge rst_n)
  // begin 
    // if (!rst_n)
	// begin
      // fifo_afull <= 4'h0;
	// end
    // else if (mltcn) 
      // begin
		  // fifo_afull[0] <= (fifo_len0 >= 15'h0FFB);
		  // fifo_afull[1] <= (fifo_len1 >= 13'h0FFB);
		  // fifo_afull[2] <= (fifo_len2 >= 13'h0FFB);
		  // fifo_afull[3] <= (fifo_len3 >= 13'h0FFB);
		  // end
    // else  
      // begin
		  // fifo_afull[0] <= (fifo_len0 >= 15'h3FFB);
		  // fifo_afull[1] <= 1'b0;
		  // fifo_afull[2] <= 1'b0; 
		  // fifo_afull[3] <= 1'b0;
      // end
  // end 
//
endmodule
