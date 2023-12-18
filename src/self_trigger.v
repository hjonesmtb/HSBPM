
//self trigger: Feb.27,2021
//1. trig active after transition time of the signal rising edge;
//2. kept in triggered mode for a time of trig_hold_max, or signal goes below threshold whichever happens first

//Feb.27,2021: trig_hold_max > 1ms, will allow a DC beam to be triggered every this time interval.
//March 9,2023: change clk to 20 Mhz, 50 ns for HSBPM project.

`timescale 1ns / 1ps
module self_trigger(
	input [DATA_WIDTH-1:0] signal, //postive always
	input [DATA_WIDTH-1:0] threshold, //positive
	input [DATA_WIDTH-1:0] transition, //number of clk 
	input clk, //clock is ADC_clk/8 = 2.5 MHz 
	input reset,
	output reg no_beam, //
	output reg gate, //window of the signal above threshold
	output all_trig //one clock pulse
);

	parameter DATA_WIDTH = 16;
	parameter CLK_T = 400 ;// clk is 2.5Mhz, ~400 ns period 
	
	parameter HOLD_TIME_ms = 4; //for CW beam signal, this will make trig every 4 ms.
   parameter HOLD_TIME = HOLD_TIME_ms*1000000/CLK_T;  // number of clock cycles
   
	parameter NO_BEAM_ms = 1000; //ms, if not trig for this period, assert No_beam.
	parameter NO_BEAM_TIME = NO_BEAM_ms*1000000/CLK_T;   // number of clock cycles
	
	parameter state_idle = 0,
             state_transition = 1, 
				 state_trig = 2, 
				 state_hold = 3;
				 
					
	reg [1:0] state;
	reg [25:0] cnt, nb_cnt; //26 bit to make sure not overflow
	reg trig, force_trig;

 //trig: real bpm signal above threshold, 
 //force_trig: no beam, fake trig to make the X,Y,SUM,Err looks like alive.
 
	assign all_trig = trig | force_trig;

always @ (posedge clk)
  if (no_beam) 
    begin 
      if (nb_cnt < HOLD_TIME ) begin force_trig <= 0; nb_cnt <= nb_cnt + 1; end
      else begin nb_cnt <= 0; force_trig <= 1; end
	 end	
  else begin nb_cnt <= 0; force_trig <= 0; end	  


always @ (posedge clk)
begin
	if(reset) begin
		state <= state_idle;
		trig <= 0; gate <= 0;
		cnt <= 0; 
	end
	
	else begin
		case(state)
		state_idle:
			if ((signal > threshold) && (signal[DATA_WIDTH-1] == 0)) 
			   begin no_beam <= 0; cnt <= 0; state <= state_transition; end
			else if (cnt < NO_BEAM_TIME) cnt <= cnt + 1;
			     else no_beam <= 1;
				
		state_transition:
			if ((signal > threshold) && (signal[DATA_WIDTH-1] == 0)) 
			   begin if (cnt >= transition) begin trig <= 1; gate <= 1; state <= state_trig; end	
				      else cnt <= cnt + 1;
				end
			else begin cnt <= 0; state <= state_idle; end
		
			
		state_trig:
		  begin trig <= 0; state <= state_hold; cnt <= 0;	end
		
		state_hold: 
		begin 
			if (cnt < HOLD_TIME) begin 
		        if ((signal < threshold) | (signal[DATA_WIDTH-1] == 1)) 
				     begin cnt <= 0; gate <= 0; state <= state_idle;	end
		        cnt <= cnt + 1;	
				end
			else begin cnt <= 0; gate <= 0; state <= state_idle; end
		end
		
		default:
		begin
			trig <= 0; cnt <= 0;
			state <= state_idle;
		end
		
		endcase
	end
end 
				

endmodule
