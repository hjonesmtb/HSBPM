`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TRIUMF
// Engineer: Shengli Liu
// 
// Create Date:    Apr. 5,2023
// Module Name:    maxmin.v
// Description:  find the max/min value from the input signal, reset until "rst" asserted
//
//////////////////////////////////////////////////////////////////////////////////
module Maxmin(
	input [SF_WIDTH-1:0] din_a,
	input [SF_WIDTH-1:0] din_b,
	input clk,
	input rst,
	
	output reg [SF_WIDTH-1:0] max_A,
	output reg [SF_WIDTH-1:0] min_A,
	output reg [SF_WIDTH-1:0] max_B,
	output reg [SF_WIDTH-1:0] min_B
    );

parameter  	SF_WIDTH = 32;
parameter  	MAX = 32'H47000000; //32768

wire max_A_update,max_B_update,min_A_update,min_B_update/*synthesis keep*/;  
reg [SF_WIDTH-1:0] din_a_1,din_b_1/*synthesis keep*/;

always @ (posedge clk)
begin
  din_a_1 <= din_a;  //delay one clk due to altfp_comp has one clk latency
  din_b_1 <= din_b;
end

always @ (posedge clk)
begin
	if(rst)	
		begin 
			max_A <= 0; max_B <= 0; 
			min_A <= MAX; min_B <= MAX; 
		end
	else 
		begin 
			if (max_A_update) max_A <= din_a_1;
			if (max_B_update) max_B <= din_b_1;			
			if (min_A_update) min_A <= din_a_1;
			if (min_B_update) min_B <= din_b_1;
			
		end
end
altfp_comp comp_inst0 (.dataa(din_a), .datab(max_A), .clock(clk), .agb(max_A_update)); 
altfp_comp comp_inst1 (.dataa(din_b), .datab(max_B), .clock(clk), .agb(max_B_update)); 

altfp_comp comp_inst2 (.dataa(din_a), .datab(min_A), .clock(clk), .alb(min_A_update)); 
altfp_comp comp_inst3 (.dataa(din_b), .datab(min_B), .clock(clk), .alb(min_B_update)); 


endmodule
