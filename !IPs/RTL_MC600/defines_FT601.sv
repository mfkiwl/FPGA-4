
package pkg_ft601_ctrl_defines ;


localparam 
			WIDTH_DATA   		= 32,

			CNT_BE				= 4,
			CNT_CHANNLS 		= 4,
			
			
			WIDTH_BUS_STATUS	= 8,
			STAUS_IND_START		= 8,
			STAUS_IND_END		= 15,
			
			CNT_CODE_NUM_CHNLS	= $clog2(CNT_CHANNLS) , // = 2,
			
			WIDTH_MEM_ADR 		= 14 ;
			
			
			
			
	
// FIFO mem param
	
	
	
`ifdef MEM_64K
  localparam 
  T_MSZ = 14,      // 64KB overall memory
  EPm_MSZ = 12,    // highest endpoint size
  // EP1_MSZ = 12,    // 16KB for endpoint 1
  // EP2_MSZ = 12,    // 16KB for endpoint 2 
  // EP3_MSZ = 12,    // 16KB for endpoint 3 
  // EP4_MSZ = 12,    // 16KB for endpoint 4

[CNT_CODE_NUM_CHNLS:0]  EP1_NUM 	   = 1,
[CNT_CODE_NUM_CHNLS:0]  EP2_NUM 	   = 2,
[CNT_CODE_NUM_CHNLS:0]  EP3_NUM 	   = 3,
[CNT_CODE_NUM_CHNLS:0]  EP4_NUM 	   = 4,
  
  // EP1_BASE_ADR = 'h0,
  // EP2_BASE_ADR = 'h1000,
  // EP3_BASE_ADR = 'h2000,
  // EP4_BASE_ADR = 'h3000,
`else

 localparam [CNT_CODE_NUM_CHNLS:0]
    EP1_NUM 	   = 1,
	EP2_NUM 	   = 2,
	EP3_NUM 	   = 3,
	EP4_NUM 	   = 4
	;

  localparam 
  T_MSZ = 12,     // 16KB overall memory
  EPm_MSZ = 10   // highest endpoint size
  // EP1_MSZ = 10,   // 4KB for endpoint 1
  // EP2_MSZ = 10,   // 4KB for endpoint 2 
  // EP3_MSZ = 10,   // 4KB for endpoint 3 
  // EP4_MSZ = 10,   // 4KB for endpoint 4 
  // EP1_BASE_ADR = 'h0,
  // EP2_BASE_ADR = 'h400,
  // EP3_BASE_ADR = 'h800,
  // EP4_BASE_ADR = 'hc00,
  
  ;
 
 

  
 
  // typedef enum logic [EPm_MSZ-1:0] 
  
  // { 
  
	// EP1_BASE_ADR = `def_EPm_MSZ'h0   ,
	// EP2_BASE_ADR = `def_EPm_MSZ'h400 ,
	// EP3_BASE_ADR = `def_EPm_MSZ'h800 ,
	// EP4_BASE_ADR = `def_EPm_MSZ'hc00
	
  // } ty_en_EP_BASE_ADR;
  


  
  
`endif		

endpackage