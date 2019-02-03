/*
  File Name     : mst_data_chk.v 
  Department    : IC Design, FTDI SGP
  Author        : Do Ngoc Duong
  History       : 25 April 2016 - Initial Version 

  Description   : This module check the received streaming data 
*/
module mst_data_chk 
#
(
parameter 

CNT_CHANNLS = 4,
WIDTH_DATA = 32
)
(
  input  rst_n, 
  input  clk,
  input  bus16,
  input  erdis, 
  input  ch_vld[CNT_CHANNLS],
  input  [WIDTH_DATA-1:0] rdata,
  output wire [CNT_CHANNLS-1:0] seq_err 
);
  // 
  reg [WIDTH_DATA-1:0] cmp_dat[CNT_CHANNLS];
  reg cmp_err[CNT_CHANNLS];

  //
  assign seq_err = {cmp_err[3],cmp_err[2],cmp_err[1],cmp_err[0]} & {CNT_CHANNLS{!erdis}};
  //245 Mode or Channel 0 of 600 Mode 
  
  integer ind;
  
  
  always @ (posedge clk or negedge rst_n)
  begin
    for( ind = 0; ind < CNT_CHANNLS ; ind++)
	begin
	
		if (!rst_n)
		  begin 
			cmp_dat[ind] <= 32'h0000_0000;
			cmp_err[ind] <= 1'b0;
		  end 
		else if (ch_vld[ind] & (!cmp_err[ind]) & (!erdis))
		begin	
			if (bus16) 
			begin
				if (rdata[15:0] == cmp_dat[ind][15:0])
				  begin  
					cmp_dat[ind] <= (&cmp_dat[ind][15:0]) ? '0 : {16'h0000,cmp_dat[ind][15:0] + 1'b1};
					cmp_err[ind] <= 1'b0;
				  end 
				else
				  begin 
					cmp_dat[ind] <= cmp_dat[ind];
					cmp_err[ind] <= 1'b1;
				  end
			end		  
			else 
			begin		
				if (rdata == cmp_dat[ind])
				  begin  
					cmp_dat[ind] <= (&cmp_dat[ind]) ? 32'h0000_0000 : cmp_dat[ind] + 1'b1;
					cmp_err[ind] <= 1'b0;
				  end 
				else
				begin 
					cmp_dat[ind] <= cmp_dat[ind];
					cmp_err[ind] <= 1'b1;
				end
			end 
		end //else rstn
	
	end //for( ind = 0; ind < CNT_CHANNLS ; ind++)
  end 
  
// 
endmodule 
