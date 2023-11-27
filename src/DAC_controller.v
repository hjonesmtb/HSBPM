/*
 * DAC controller: based on DAC_control.v of Digital Toroid Processor project
 * 1. create 2 DAC signals represent Peak and Avg value;
 * 2. Both Peak and Avg are relative value in units of mV;
 
 * data rate : < 1 MHz
 * Shengli Liu, January 5,2021
 */
module DAC_control
    (
        // Signals to DAC 
        output   sdi_A,   // SPI data to DAC A
		  output   sdi_B,   // SPI data to DAC B
        output   sclk,   // SPI_CLK to DAC, less than 50 MHz                                                     
        output   ss,     // start                                    
         
        // Signals to/from system
		 
		  input [15:0] PEAK, //beam peak value, DAC bin
		  input [15:0] AVG, //beam avg value, DAC bin
        input   clk,  //50MHz system clock                                                      
        input   rst
        
		  
    );

    parameter   state_idle = 0, 
	             state_pulse_off = 1;
					 

	 
	 parameter DAC_DATA_WIDTH = 16;  				 
	 parameter DAC_FREQ = 1; //1MSPS, 
    parameter CLK_FREQ = 50; //50MHZ 
    parameter DIV = CLK_FREQ/DAC_FREQ; 
	 parameter PERIOD = 16'd44405; //=50MHz/1126 Hz 
	// parameter PERIOD = 16'd11100; //temporary for testing
	 
	 reg [1:0] state; /*synthesis keep*/

    reg [15:0] cnt; /*synthesis keep*/
	 reg [15:0] timer_cnt;
		 
	 reg [DAC_DATA_WIDTH-1:0] DAC_A_code,DAC_B_code;  /*synthesis keep*/
       
    reg  start_pulse; /*synthesis keep*/
	 reg  DAC_update;  /*synthesis keep*/
	 
	    
always @ (posedge clk)  
begin 
		if (timer_cnt >= PERIOD) begin timer_cnt <= 0; start_pulse <= 1; end
		else begin start_pulse <= 0; timer_cnt <= timer_cnt + 1; end
end   


////////////////////////////////////////////////////////////////////////////
always @ (posedge clk) 
begin
	if (rst) 
		begin
			state <= state_idle;
			cnt <= 0;
		end
	else 
		case (state)
				state_idle:									
					begin 
						if (start_pulse)	
						   begin DAC_A_code <= PEAK; DAC_B_code <= AVG; DAC_update <= 1; state <= state_pulse_off;	end		
					end
				state_pulse_off: begin DAC_update <= 0; state <= state_idle; end
				
				default:
				  state <= state_idle;
		
		endcase
		
end //end always


DAC DAC_PEAK_inst
    ( 
	   .sdi(sdi_A),   // SPI data to DAC
      .sclk(sclk),   // SPI_CLK to DAC, less than 50 MHz                                                     
      .ss(ss),     // start 
		
 		.code(DAC_A_code), // code = 0 ~ FSR, i.g. 0 ~ 65535
      .clk(clk),                                                         
      .rst(rst),
		.update(DAC_update)
	
	 );
	 
DAC DAC_AVG_inst
    ( 
	   .sdi(sdi_B),   // SPI data to DAC
      .sclk(),   //                                                  
      .ss(),     // 
		
 		.code(DAC_B_code), // code = 0 ~ FSR, i.g. 0 ~ 65535
      .clk(clk),                                                         
      .rst(rst),
		.update(DAC_update)
	
	 );	 
 

endmodule // 
