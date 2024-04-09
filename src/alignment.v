
//alignment: March 31,2023
//1. create the gate signal so it only contains the signal on the plateau of the signal pulse,
//2. delay the input signal so the new gate could match it.

//i.e. exclued the rising and falling edges 
//method: 1. the input gate signal contains the transition part;
// 2. this gate needs to be cut in both side for transition
// 3. the transition should be very small, for now I used 4 clk = 1.6 us 

// Modified Apr 05 2024 to use a variable transition. The 16 clk fixed value is cutting off short pulses - HJ
 
`timescale 1ns / 1ps
module alignment( 
	input [FULL_WIDTH-1:0] signal, //postive always
	input gate, 
	input [DATA_WIDTH-1:0] transition, //number of clk
	input clk, //clock is ADC_clk/8 = 2.5 MHz 
	input reset,	
	output reg [FULL_WIDTH-1:0] signal_delayed,
	output reg new_gate
);

	parameter DATA_WIDTH = 16;
	parameter FULL_WIDTH = 64;
	
	parameter state_idle = 0,
             state_transition = 1, 
				 state_gate = 2;
				 
//
//	parameter MAX_TRANSITION = 63;
//	reg [FULL_WIDTH-1:0] sig [MAX_TRANSITION:0]; // previous 64 signals
//	wire [5:0] trans = (transition >= MAX_TRANSITION)? MAX_TRANSITION: transition; // limit transition to 64 clks
//
//	integer i;
//	always @ (posedge clk)
//    begin 
//		sig[0] <= signal;
//      for (i = 1; i<=trans; i=i+1) begin
//			sig[i] <= sig[i-1];
//		end
//		signal_delayed <= sig[trans];
//	 end	
	 

parameter DELAY = 10;	//new gate needs to be delayed by 4 times of TRANSITION

reg [1:0] state;		
reg [FULL_WIDTH-1:0] sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7;
reg [FULL_WIDTH-1:0] sig_8,sig_9,sig_10,sig_11,sig_12,sig_13,sig_14;
reg [7:0] cnt;
	
always @ (posedge clk)
    begin 
      sig_1 <= signal;
		sig_2 <= sig_1;
		sig_3 <= sig_2;
		sig_4 <= sig_3;
		sig_5 <= sig_4;
		sig_6 <= sig_5;
		sig_7 <= sig_6;
		sig_8 <= sig_7;
		sig_9 <= sig_8;
		sig_10 <= sig_9;
		sig_11 <= sig_10;
		sig_12 <= sig_11;
		sig_13 <= sig_12;
		sig_14 <= sig_13;
		signal_delayed <= sig_8;	// changed to delay of 9 vs 15
	 end	
 

always @ (posedge clk)
begin
	if(reset) begin
		state <= state_idle;
		new_gate <= 0;
		cnt <= 0;
	end
	else begin
		case(state)
		state_idle:
			if (gate) begin cnt <= 0; state <= state_transition; end				
		state_transition:
			if (cnt >= DELAY) begin new_gate <= 1; state <= state_gate; end	
			else cnt <= cnt + 1;
		state_gate:
		  if (~gate) begin new_gate <= 0; state <= state_idle; end		
		default:
		begin
			new_gate <= 0; 
			state <= state_idle;
		end
		
		endcase
	end
end 
				

endmodule
