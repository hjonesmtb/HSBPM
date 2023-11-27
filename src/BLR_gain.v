`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  TRIUMF
// Engineer: Shengli Liu
// Modified from awake bpm module: BLR_gain
// once circular buffer "event_rdy" is asserted, read from it and write to fast fifo
///////////////////////////////////////////////////////////////////////////////////
module BLR_GAIN(
   RUN,
   rst,
	clk,

	fifo_full,
	fifo_empty,
	
	event_rdy,
	rd,    		//read Circular channel buffer 
	wr,
	
	busy          //to prevent the Fast fifo to be readout by MB
	

    );

parameter  	ADC_BIT_WIDTH = 16;
parameter  	DATA_WIDTH = 16;

 input rst;
 input clk;
 input RUN;
 
 input fifo_full,fifo_empty;
  
 input event_rdy;
  
 output reg rd,wr;

 output reg busy;
 

parameter  state_idle = 0; //
parameter  state_wait1 = 1; //
parameter  state_wait2 = 2; //
parameter  state_load = 3; //
parameter  state_load_loop = 4; //

reg [2:0] state/*synthesis keep*/;

wire [4*ADC_BIT_WIDTH-1:0] dout_BLR; 


always @ (posedge clk) 
begin
	if (rst) 
		begin
			state <= state_idle;
			rd <= 0;
			wr <= 0;
			busy <= 0;
						
		end
	else 
		case (state)
				state_idle:									
					begin  
						if((event_rdy == 1) && RUN)	
						  begin 
						    busy <= 1;							 
							 state <= state_wait1; 
						  end				
					end
				state_wait1:
					begin 
					  if (fifo_empty && ~fifo_full)  state <= state_wait2; 					  				  
		         end						
				state_wait2:
					begin 
					  rd <= 1;
                 state <= state_load; 					  				  
		         end	
				state_load:  //now apply BL restoration
					begin          					  
					  wr <= 1;  
					  state <= state_load_loop; 		
		         end
				state_load_loop:
					begin  
                 if (event_rdy == 0 || fifo_full)  begin
					     rd <= 0;
						  wr <= 0;
            		  busy <= 0;
					     state <= state_idle;
					  end	  
				   end	
	
				default:
				  state <= state_idle;
		
		endcase
		
end //end always


endmodule
	