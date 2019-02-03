
package pkg_ft601_ctrl_defines ;


localparam 
			WIDTH_DATA   		= 32,
			WIDTH_PREF_DATA 	= 36,
			CNT_BE				= 4,
			CNT_CHANNLS 		= 4,
			CNT_CODE_NUM_CHNLS	= $clog2(CNT_CHANNLS) , // = 2,
			
			WIDTH_MEM_ADR 		= 14 ;

endpackage