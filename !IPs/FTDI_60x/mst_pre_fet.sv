/*
  File Name     : mst_pre_fet.v  
  Department    : IC Design, FTDI SGP
  Author        : Do Ngoc Duong
  History       : 30 June 2016 - Initial Version 

  Description   : This module contains pre-fetch data 
*/

module mst_pre_fet
#
(
parameter 

ADDRBIT 			= 2,
LENGTH  			= 4,
WIDTH_DATA   	  	= 32,
WIDTH_PREF_DATA   	= 36,
CNT_CHANNLS 		= 4,

CNT_CODE_NUM_CHNLS	= $clog2(CNT_CHANNLS)  // = 2,
)
 
(
input clk,
input rst_n,
 //Flow control interface
input 							pref_ena,       	// pre-fetch enable 
input 							pref_req,       	// pre-fetch data request signal
input 							pref_mod,	    	// pre-fetch mode: 1 streamming 0 loop-back 
input [CNT_CODE_NUM_CHNLS-1:0]  pref_chn,	    	// pre-fetch channel 
output[CNT_CHANNLS-1:0]  		pref_nempt,     	// pre-fetch data not empty 
output[WIDTH_PREF_DATA -1:0] 	pref_dout,      	// pre-fetch data out
 //Internal FIFO interface  
output  						i_fifo_rd,       // internal FIFO read request 
input [CNT_CHANNLS-1:0] 		i_fifo_nempt,       // internam FIFO not empty 
input [WIDTH_PREF_DATA -1:0] 	i_fifo_dat,      // internal FIFO data 
//Streaming generate interface 
output gen_req					[CNT_CHANNLS],        // Generate request channel 0

input[WIDTH_DATA-1:0] gen_dat	[CNT_CHANNLS]        // Generate data channel 0

);

//*********************************************

// //Assigns

reg     [ADDRBIT:0]     	pref_len [CNT_CHANNLS];

reg     [ADDRBIT-1:0]     	wr_cntr [CNT_CHANNLS];
wire    [ADDRBIT-1:0]   	rd_cntr[CNT_CHANNLS];
//wire    [CNT_CODE_NUM_CHNLS-1:0] 	pref_nempt; 
wire    [CNT_CHANNLS-1:0] 			pref_full;
wire    							pref_wr;
 
wire    							write;
wire    							read;



integer ind;

always_comb
begin

	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin
	
		pref_nempt[ind] =  (pref_len[ind] != {1'b0,{ADDRBIT{1'b0}}});

		pref_full[ind]  =  (pref_len[ind][ADDRBIT-1]);
		
		rd_cntr[ind]    =  wr_cntr[ind] - pref_len[ind][ADDRBIT-2:0];

 
	end
end


assign  write       =   (pref_wr & !pref_full[pref_chn]);
assign  read        =   (pref_req & pref_nempt[pref_chn]);
// 

integer     i;
reg [WIDTH_PREF_DATA-1:0] pref_dat[CNT_CHANNLS] [LENGTH-1:0];

reg [WIDTH_PREF_DATA-1:0] pref_din; 
//
always_ff @(posedge clk or negedge rst_n)
begin

for(ind = 0; ind < CNT_CHANNLS; ind ++)
begin 
	if(!rst_n) 
	begin
		for(i = 0 ; i < LENGTH; i ++)
		begin 
		
				pref_dat[ind][i]      <= 'b0;

		end
	end
	else if(write)
	begin
		// case (pref_chn) 
			// ind: pref_dat[ind][wr_cntr[ind]] <= pref_din;

		// endcase	
			if(pref_chn == ind )
			begin
				pref_dat[ind][wr_cntr[ind]] <= pref_din;
			end
		
			
	end
end//for(ind = 0; ind < CNT_CHANNLS; ind ++)	
				 	
end
// 
always @(posedge clk or negedge rst_n)
begin
 
	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin  
			if(!rst_n) 
			begin
				
				wr_cntr[ind] <= '1;

			end 
			else if(write)
			begin
				case (pref_chn)
				  ind:  wr_cntr[ind] <= wr_cntr[ind] + 1'b1;

				endcase
			end
	end
end  
// 
always @(posedge clk or negedge rst_n)
begin

for(ind = 0; ind < CNT_CHANNLS; ind ++)
begin

	if(!rst_n) 
	begin
		pref_len[ind]  <= {1'b0,{ADDRBIT{1'b0}}};
	end
	else if (pref_chn == 2'b00)
	begin

		case({read,write}) // synthesis full_case
		  2'b01:   pref_len[ind] <= pref_len[ind] + 1'b1;
		  2'b10:   pref_len[ind] <= pref_len[ind] - 1'b1;
		  default: pref_len[ind] <= pref_len[ind];
		endcase

	end
end //for(ind = 0; ind < CNT_CHANNLS; ind ++)
  
end

wire [WIDTH_PREF_DATA-1:0] pref_dout_buf[CNT_CHANNLS];
wire[3:0] pre_not_ful; 
//wire [WIDTH_PREF_DATA-1:0] pref_dout; 

always_comb
begin

	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin

		 pref_dout_buf[ind] = pref_dat[ind][rd_cntr[ind]];
         //assign pref_dout[0] = prefdat0[rdcnt0]; 
		 	 
		//Internal FIFO control

		pre_not_ful[ind] = (pref_len[ind] < 3);

	end
	
	pref_dout = pref_dout_buf[pref_chn];
	
end

//read data from FIFO
wire data_req;
//wire i_fifo_rd;  
assign data_req = pref_ena && pre_not_ful[pref_chn] && (i_fifo_nempt[pref_chn] | pref_mod) ;
assign i_fifo_rd = data_req && (!pref_mod);  
// 
reg data_req_buf;
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n) 
    data_req_buf <= 1'b0;
  else
    data_req_buf <= data_req; 
end
//
assign pref_wr = data_req_buf;
// 
//wire gen_req [ CNT_CHANNLS];

always @(posedge clk or negedge rst_n)
begin

if(!rst_n)
begin

	pref_din <= '0;

end
else
begin


		if (!pref_mod)
		begin
			pref_din <= i_fifo_dat; 
		end
		else 
		begin
		
			for(ind = 0; ind < CNT_CHANNLS; ind ++)
			begin
				
				if(pref_chn == ind)
				begin
				 pref_din <= {4'hf,gen_dat[ind]};

				end 
			end
		end

end
		
end


always_comb
begin

	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin
		gen_req[ind] = data_req & (pref_chn == 2'b00) & pref_mod; 
	end	


end

// 
endmodule 
