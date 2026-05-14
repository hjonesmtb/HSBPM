`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: 


//////////////////////////////////////////////////////////////////////////////////
module BPM_trip(
   input DCLK,   // 2.5 MHz
	input [31:0] X_fp,
	input [31:0] Y_fp,
	input clear_trip, // reset bpm_ok
	output reg tripped_reg = 0,
	output bpm_ok // 2.5 MHz clock when OK

    );
	
	// trip when X or Y is out of range (+- 20 mm)
	wire trip_x_high, trip_x_low, trip_y_high, trip_y_low;
	wire tripped = trip_x_high | trip_y_high | trip_x_low | trip_y_low; 
	
	assign bpm_ok = !tripped_reg & DCLK;
	
	// pos > +20mm
	altfp_comp comp_inst1 (.dataa(X_fp), .datab(32'h41a00000), .clock(DCLK), .agb(trip_x_high), .alb() );
	altfp_comp comp_inst2 (.dataa(Y_fp), .datab(32'h41a00000), .clock(DCLK), .agb(trip_y_high), .alb() );

	// pos < -20mm
	altfp_comp comp_inst3 (.dataa(X_fp), .datab(32'hc1a00000), .clock(DCLK), .agb(), .alb(trip_x_low) );
	altfp_comp comp_inst4 (.dataa(Y_fp), .datab(32'hc1a00000), .clock(DCLK), .agb(), .alb(trip_y_low) );
	
	reg clear_trip_resyn1, clear_trip_resyn2;	
	always@(posedge DCLK) begin // for synchronous reset
		clear_trip_resyn1 <= clear_trip;
		clear_trip_resyn2 <= clear_trip_resyn1;
		
		case({tripped,clear_trip_resyn2})
		  2'b00: tripped_reg <= tripped_reg; // No change
		  2'b01: tripped_reg <= 1'b0; // reset
		  2'b10: tripped_reg <= 1'b1; // set
		  2'b11: tripped_reg <= 1'b1; // Invalid inputs
		endcase

	end
	
endmodule
