/*
 * create self test pulse: 
 * 1. create 1126 Hz pulse, duty cycle variable. 
 * Shengli Liu, Oct.25,2020
 * 
 * Removed divide to fix timing issues - HJ Nov 2026
 */
module Self_Test
    ( 
		  input   clk,  //50MHz system clock                                                      
        input   rst,
		  
		  input [7:0] Dcycle, //duty cycle: 0 ~ 100, unit:% 
		  output trig, //for auto trigger 
	     output reg pulse    
		  
    );

    parameter   state_idle = 0, 
	             state_pulse_on1 = 1,
					 state_pulse_on2 = 2,
					 state_pulse_off = 3;
					 
    parameter CLK_FREQ = 50; //50MHZ 
	 parameter PERIOD = 16'd44405; //=50MHz/1126 Hz 
	 parameter PERIOD_div100 = 16'd444; //=50MHz/1126/100 Hz 
	// parameter PERIOD = 16'd11100; //temporary for testing
	 
	 reg [1:0] state; /*synthesis keep*/

    reg [15:0] cnt; /*synthesis keep*/
	 reg [15:0] timer_cnt;
		 
       
    reg  start_pulse; /*synthesis keep*/
	 assign trig = start_pulse;
	 
	 wire [15:0] high_level/*synthesis keep*/;
	 wire [15:0] low_level/*synthesis keep*/; 
	 wire unsigned [31:0] on_time/*synthesis keep*/;
	     
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
						if (start_pulse)	//duty cycle != 0
						   if (|Dcycle) 
								begin  
									cnt <= 0; pulse <= 1; 
									state <= state_pulse_on1; 
							   end	
					end
				state_pulse_on1:  
				   begin 
					  if (cnt >= on_time[15:0]) begin pulse <= 0; state <= state_idle; end
					  else cnt <= cnt + 1; 	
		         end 

					
				default:
				  state <= state_idle;
		
		endcase
		
end //end always

 
wire unsigned [31:0] mul_p1/*synthesis keep*/;  
lpm_mul_unsigned	mul_const1 (
		.dataa(PERIOD), //16 bit
		.datab(Dcycle),  //16 bit
		.result(mul_p1)  //32 bit
		);	

lpm_mul_unsigned	mul_const2 (
	.dataa(PERIOD_div100), //16 bit
	.datab(Dcycle),  //16 bit
	.result(on_time)  //32 bit
);	
		
//lpm_div div_const1(
//	.denom(16'd100), //16 bit
//	.numer(mul_p1),  //32 bit
//	.quotient(on_time), //32 bit
//	.remain());        //16 bit


	
endmodule // 
