/*
  File Name     : mst_data_gen.v 
  Department    : IC Design, FTDI SGP
  Author        : Do Ngoc Duong
  History       : 25 April 2016 - Initial Version 

  Description   : This module generates the streaming data 
*/

import pkg_ft601_ctrl_defines::*;

module mst_data_gen 
// #
// (
// parameter 

// CNT_CHANNLS = 4,
// WIDTH_DATA = 32

// )

(
  input rst_n, 
  input clk,
  input bus16,
  input ch_req[CNT_CHANNLS],
  output [WIDTH_DATA-1:0] ch_dat[CNT_CHANNLS]

);
  
  integer ind;
  always_ff @ (posedge clk or negedge rst_n)
  begin
    
	for(ind = 0; ind < CNT_CHANNLS; ind ++)
	begin
		if (!rst_n)
		begin
			ch_dat[ind] <= '1;
		end
		else if (ch_req[ind])  
		begin
		  if (bus16) 
				ch_dat[ind] <= (&ch_dat[ind][WIDTH_DATA/2-1:0]) ? '0 : {{(WIDTH_DATA/2){1'b1}},ch_dat[ind][WIDTH_DATA/2-1:0] + 1'b1};
		  else  
				ch_dat[ind] <= (&ch_dat[ind]) ? '0 : ch_dat[ind] + 1'b1;
				
		end		
	end	//for(ind = 0; ind < CNT_CHANNLS; ind ++)	
  end 
 
  //  
endmodule 
