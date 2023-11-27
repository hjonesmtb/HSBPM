`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Calculate signal energy of input signal by approximating the area using rectangles
// 
// by: Yuhai Li, Diagnostics Coop Student, TRIUMF
// History: Created on January 17, 2022
//
//////////////////////////////////////////////////////////////////////////////////

module cal_riemann(
	input [DATA_WIDTH-1:0] A_amp, B_amp, //16 bit amplitude signal, always positive
	input clk, //750kHz, same as ADC clk
	input rst,
	input start,
	
	output reg [SUM_WIDTH-1:0] energy_A, energy_B, // 32 bit output signal, always positive
	output reg Valid
	
	);
	
parameter DATA_WIDTH = 16;
parameter SUM_WIDTH = 32;
//parameter CLK_INT_DIV = 500;
parameter CLK_INT_DIV = 100;
//parameter CLK_INT_DIV = 750; // this integration period captures full duty cycle

reg [SUM_WIDTH-1:0] Acc, Bcc;
reg [9:0] clk_cnt; //2^10 = 1024 > 1000, used for freq divison
reg state;

always @ (posedge clk or posedge rst)
begin
	
	if (rst) begin clk_cnt <= 0; Acc <= 0; Bcc <= 0; energy_A <= 0; energy_B <= 0; Valid <= 0; state <= 0; end
	else begin
		case(state)
		
			0:	if (start) begin clk_cnt <= 0; Acc <= 0; Bcc <= 0;	Valid <= 0; state <= 1; end
				else begin clk_cnt <= 0; Acc <= 0; Bcc <= 0;	Valid <= 0; end
			
			1:	if (clk_cnt > (CLK_INT_DIV - 1)) begin
					clk_cnt <= 0; energy_A <= Acc; energy_B <= Bcc; Acc <= 0; Bcc <= 0; Valid <= 1; state <= 0;
				end
				else begin clk_cnt <= clk_cnt + 1; Acc <= Acc + A_amp; Bcc <= Bcc + B_amp; Valid <= 0; end
		endcase
	end
end

endmodule