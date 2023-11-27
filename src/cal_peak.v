`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// calcualte for peak: from input signal  
// 
// by: Shengli Liu, Diagnostics, TRIUMF
// Histroy: Created on March 1, 2021
//
//////////////////////////////////////////////////////////////////////////////////

module cal_peak(
	input [DATA_WIDTH-1:0] A_amp,B_amp,//16 bit, amplitude signal 
	input clk,  // 
	input rst,
   input start, //start to summing the signal,
   input [1:0] AVG_sel, //avgeraing samples = 128,256, 512,1024
	
  	output reg signed [DATA_WIDTH-1:0] peak_A,peak_B,//16 bit signed in DAC value. 
	output reg Valid
	
    );

parameter DATA_WIDTH = 16;  

reg signed [25:0] Acc,Bcc;
reg [10:0] N/*synthesis keep*/; 

wire [10:0] N_samples = (AVG_sel == 2'b00)? 128
                     : (AVG_sel == 2'b01)? 256
						   : (AVG_sel == 2'b10)? 512
							: (AVG_sel == 2'b11)? 1024 : 128;
							
wire [DATA_WIDTH-1:0] Acc_div = (AVG_sel == 2'b00)? Acc[22:7]
                     : (AVG_sel == 2'b01)? Acc[23:8]
							: (AVG_sel == 2'b10)? Acc[24:9]
							: (AVG_sel == 2'b11)? Acc[25:10] : Acc[22:7];		
							
wire [DATA_WIDTH-1:0] Bcc_div = (AVG_sel == 2'b00)? Bcc[22:7]
                     : (AVG_sel == 2'b01)? Bcc[23:8]
							: (AVG_sel == 2'b10)? Bcc[24:9]
							: (AVG_sel == 2'b11)? Bcc[25:10] : Bcc[22:7];								
					
reg [1:0] state/*synthesis keep*/;
always @ (posedge clk )	
begin
   case(state)
		0: if (start) begin Valid <= 0; Acc <= 0; Bcc <= 0; N <= 0;  state <= 1; end 
		   else begin Valid <= 0; Acc <= 0; Bcc <= 0; N <= 0; end
		1: if ( N > (N_samples-1)) state <= 2; 
			else begin 
					 Acc <= Acc + A_amp; Bcc <= Bcc + B_amp; N <= N + 1; 
				  end 
		2: begin 
		     
		peak_A <= Acc_div; peak_B <= Bcc_div; Valid <= 1;  state <= 0; end //divided by 2**NB = N_samples
	
	   default: state <= 0;
	endcase
end	

endmodule