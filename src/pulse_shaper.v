`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// shaping pulse
//////////////////////////////////////////////////////////////////////////////////
module pulse_shaper(
	input data_in,
	input clk,
	output reg data_out
    );
	 
parameter LENGTH = 30; //streach 30 clk
reg [7:0] cnt;
reg state;

always @ (posedge clk)
  begin
   case(state)
		0: if (data_in) begin data_out <= 1; cnt <= 0; state <= 1; end 
			else begin data_out <= 0; cnt <= 0; end 
		1: if ( cnt > LENGTH) begin data_out <= 0; state <= 0; end
			else cnt <= cnt + 1; 	
	   default: state <= 0;
	endcase
  end

endmodule
