`timescale 100ps / 1ps

module FIR(
	input clk, // 20 MHz
	input reset,
	input ena_gain, // 1 for additional 4x gain
	input wire signed [13:0] data_in, // 14 bit ADC data
	output reg signed [15:0] data_out
    );

	// define delay unit , input width is 16  , filter order is 16
	reg signed [13:0] delay_pipeline[14:0];
	
	// define coef
	wire signed [15:0]  coef[14:0];
	assign coef[0] = 833;
	assign coef[1] = 856;
	assign coef[2] = -3016;
	assign coef[3] = 1014;
	assign coef[4] = 4446;
	assign coef[5] = -4901;
	assign coef[6] = -2262;
	assign coef[7] = 7109;
	assign coef[8] = -2262;
	assign coef[9] = -4901;
	assign coef[10] = 4446;
	assign coef[11] = 1014;
	assign coef[12] = -3016;
	assign coef[13] = 856;
	assign coef[14] = 833;	
														
	// define multipler
	reg signed [31:0]  product[14:0];

	// define sum buffer
	reg signed [31:0]  sum_buf;	

	// define input data buffer
	reg signed [13:0] data_in_buf;

	// data buffer
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			data_in_buf <= 0;
		end
		else begin
			data_in_buf <= data_in;
		end
	end

	// delay units pipeline
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			delay_pipeline[0] <= 0 ;
			delay_pipeline[1] <= 0 ;
			delay_pipeline[2] <= 0 ;
			delay_pipeline[3] <= 0 ;
			delay_pipeline[4] <= 0 ;
			delay_pipeline[5] <= 0 ;
			delay_pipeline[6] <= 0 ;
			delay_pipeline[7] <= 0 ;
			delay_pipeline[8] <= 0 ;
			delay_pipeline[9] <= 0 ;
			delay_pipeline[10] <= 0 ;
			delay_pipeline[11] <= 0 ;
			delay_pipeline[12] <= 0 ;
			delay_pipeline[13] <= 0 ;
			delay_pipeline[14] <= 0 ;
		end 
		else begin
			delay_pipeline[0] <= data_in_buf ;
			delay_pipeline[1] <= delay_pipeline[0] ;
			delay_pipeline[2] <= delay_pipeline[1] ;
			delay_pipeline[3] <= delay_pipeline[2] ;
			delay_pipeline[4] <= delay_pipeline[3] ;
			delay_pipeline[5] <= delay_pipeline[4] ;
			delay_pipeline[6] <= delay_pipeline[5] ;
			delay_pipeline[7] <= delay_pipeline[6] ;
			delay_pipeline[8] <= delay_pipeline[7] ;
			delay_pipeline[9] <= delay_pipeline[8] ;
			delay_pipeline[10] <= delay_pipeline[9] ;
			delay_pipeline[11] <= delay_pipeline[10] ;
			delay_pipeline[12] <= delay_pipeline[11] ;
			delay_pipeline[13] <= delay_pipeline[12] ;
			delay_pipeline[14] <= delay_pipeline[13] ;
		end
	end

	// implement product with coef 
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			product[0] <= 0;
			product[1] <= 0;
			product[2] <= 0;
			product[3] <= 0;
			product[4] <= 0;
			product[5] <= 0;
			product[6] <= 0;
			product[7] <= 0;
			product[8] <= 0;
			product[9] <= 0;
			product[10] <= 0;
			product[11] <= 0;
			product[12] <= 0;
			product[13] <= 0;
			product[14] <= 0;
		end
		else begin
			product[0] <= coef[0] * delay_pipeline[0];
			product[1] <= coef[1] * delay_pipeline[1];
			product[2] <= coef[2] * delay_pipeline[2];
			product[3] <= coef[3] * delay_pipeline[3];
			product[4] <= coef[4] * delay_pipeline[4];
			product[5] <= coef[5] * delay_pipeline[5];
			product[6] <= coef[6] * delay_pipeline[6];
			product[7] <= coef[7] * delay_pipeline[7];
			product[8] <= coef[8] * delay_pipeline[8];
			product[9] <= coef[9] * delay_pipeline[9];
			product[10] <= coef[10] * delay_pipeline[10];
			product[11] <= coef[11] * delay_pipeline[11];
			product[12] <= coef[12] * delay_pipeline[12];
			product[13] <= coef[13] * delay_pipeline[13];
			product[14] <= coef[14] * delay_pipeline[14];
		end
	end

	// accumulation
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			sum_buf <= 0;
		end
		else begin
			sum_buf <= product[0] + product[1]+ product[2]+ product[3]+ product[4]
			+ product[5]+ product[6]+ product[7]+ product[8]+ product[9]+ product[10]
			+ product[11]+ product[12]+ product[13]+ product[14];
		end
	end

	always @(sum_buf) begin
		if (reset) begin
			data_out = 0;
		end
		else begin 
			data_out = ena_gain? (sum_buf >>> 13) : (sum_buf >>> 15); // = 4*(sum_buf >>> 15)
		end 
	end

endmodule