//CIC35.v: CIC filter N=3, R=8, M=1, Bitgrowth = Nlog2(RM) = 9, 
//so Max BitWidth = 32 + 9 = 41

`timescale 1ns / 1ps
module CIC38 #(parameter width = 41)
			(
			input  clk,
			input  rst,
			input  signed [31:0]  d_in,
			output reg signed [31:0]  d_out,
			output reg clk_en,  
			output reg d_clk);


parameter decimation_ratio = 8;
			
reg signed [width-1:0] d_tmp, d_d_tmp;


// Integrator stage registers

reg signed [width-1:0] d1;
reg signed [width-1:0] d2;
reg signed [width-1:0] d3;

// Comb stage registers

reg signed [width-1:0] d6, d_d6;
reg signed [width-1:0] d7, d_d7;
reg signed [width-1:0] d8, d_d8/*synthesis keep*/;

reg [7:0] count;

reg v_comb;  // Valid signal for comb section running at output rate

reg d_clk_tmp;

always @(posedge clk) 
   if (count == 0) clk_en <= 1'b1;
	else clk_en <= 1'b0;
 
always @(posedge clk)
	begin
		if (rst)
		begin
			d1 <= 0;
			d2 <= 0;
			d3 <= 0;
			count <= 0;
		end else
		begin
			// Integrator section
			d1 <= d_in + d1;
			d2 <= d1 + d2;
			d3 <= d2 + d3;
			
			// Decimation
			if (count == decimation_ratio-1)
			begin
				count <= 8'b0;
				d_tmp <= d3;
				d_clk_tmp <= 1'b1;
				v_comb <= 1'b1;
			end else if (count == (decimation_ratio >> 1) -1)
			begin
				d_clk_tmp <= 1'b0;
				count <= count + 8'd1;
				v_comb <= 1'b0;
			end else
			begin
				count <= count + 8'd1;
				v_comb <= 1'b0;
			end
		end
	end
	
	always @(posedge clk)  // Comb section running at output rate
	begin
		d_clk <= d_clk_tmp;
		if (rst)
		begin
			d6 <= 0;
			d7 <= 0;
			d8 <= 0;
			d_d6 <= 0;
			d_d7 <= 0;
			d_d8 <= 0;
			d_out <= 0;
		end else
		begin
			if (v_comb)
			begin
				// Comb section
				d_d_tmp <= d_tmp;
				
				d6 <= d_tmp - d_d_tmp;
				d_d6 <= d6;

				d7 <= d6 - d_d6;
				d_d7 <= d7;

				d8 <= d7 - d_d7;
				d_d8 <= d8;
		
				//d_out <= d8 >>> (width - 16);
				d_out <= d8 >>> (width - 32); //keep 32 bit output
			end
		end
	end	

	
endmodule