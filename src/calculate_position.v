`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// calcualte X, Y postion 
// 
// by: Holden Jones, Diagnostics, TRIUMF
// History: Adapted from Shengli Liu 
// 
//////////////////////////////////////////////////////////////////////////////////

// ~78 clk latency = 31 us
module calculate_position(
   
	input [SF_WIDTH-1:0] A_amp, //fp 32 bit, amplitude signal 
	input [SF_WIDTH-1:0] B_amp,
	input data_valid, //new data, one clk pulse
	
	input [DATA_WIDTH-1:0] OFFSET,//offset adjust, um
	input [SF_WIDTH-1:0] FP_CH2_NF, //gain compensation for Ch2. Around 1.0
	
	input [SF_WIDTH-1:0] FP_KXY, //= Kx, Ky, BPM sensitivity
	input LPF_en, //select AVG time for peak calculating
	input clk_fast,  //decimated clk: 2.5 MHz 
	input rst,
	input gate, 
   	
	//input [SF_WIDTH-1:0] K1, //
	input [SF_WIDTH-1:0] IIR_OUT_K2, //LPF K2, fp
	input dead_zone,
	input decimate,
	input flip_sign,
	output [SF_WIDTH-1:0] A_comp,
	output [SF_WIDTH-1:0] B_comp,
	
	output [SF_WIDTH-1:0] A_max,
	output [SF_WIDTH-1:0] B_max,
	output [SF_WIDTH-1:0] A_min,
	output [SF_WIDTH-1:0] B_min,
	
	output [SF_WIDTH-1:0] fp_pos_mm_LPF,
	output [SF_WIDTH-1:0] fp_pos_slow // changed
	
    );
	 
parameter SF_WIDTH = 32; 
parameter DATA_WIDTH = 16;
parameter SUM_WIDTH = 32; 

parameter fp1 = 32'H3f800000; //1
parameter fp100 = 32'H42c80000; //100
parameter fp_neg100 = 32'Hc2c80000; //-100
parameter fpdot001 = 32'H3a83126f; //0.001
parameter fpdot2 = 32'H3e4ccccd; // = 1/5 = 0.2

reg [SF_WIDTH-1:0] A_in, B_in/*synthesis keep*/;
wire [SF_WIDTH-1:0] fp_X_OFFSET, Kxy,delta, sigma;
wire [SF_WIDTH-1:0] A,B,C,D,fpOFFSETmm,fp_pos_dac,fp_pos_mm/*synthesis keep*/;
wire sigma_zero;
wire [SF_WIDTH-1:0] sigma_div = sigma_zero? fp1 : sigma;

reg [SF_WIDTH-1:0] A_scale,B_scale; // calibration values for each channel
reg [SF_WIDTH-1:0] scale;
 
always @ (posedge clk_fast) begin
	
		if (gate && !dead_zone) begin 
			A_scale <= fp1;
			B_scale <= FP_CH2_NF;
	
			A_in <= A_amp;
			B_in <= B_amp; 	
			
			// reverse sign when inputs are swapped
			// delay not accounted for. May cause glitching/noise.
			if(flip_sign) begin
				scale <= fp_neg100; 
			end
			else begin
				scale <= fp100;
			end
		end			
	end

// create integer version of position
wire signed [31:0] pos_slow, pos_fast;
wire clk_slow;
altfp_fp2int32 fp2int_inst1(.dataa(fp_pos_mm_LPF),.clock(clk_fast),.result(pos_fast));

// decimate and filter integer position
CIC38 CIC(
			.clk(clk_fast),
			.rst(rst),
			.d_in(pos_fast),
			.d_out(pos_slow),
			.clk_en(),
			.d_clk(clk_slow));
			

altfp_32int2fp int2fpconv_inst1 (.dataa(pos_slow), .clock(clk_slow), .result(fp_pos_slow)); 
wire [SF_WIDTH-1:0] A_fp, B_fp;
wire clk;

assign A_fp = A_in;
assign B_fp = B_in;
assign clk = decimate? clk_slow: clk_fast;

	
Maxmin maxmin_inst(
	.din_a(A_fp),
	.din_b(B_fp),
	.clk(clk),
	.rst(rst),
	
	.max_A(A_max),
	.min_A(A_min),
	.max_B(B_max),
   .min_B(B_min)
    );	

wire [SF_WIDTH-1:0] A_sub, B_sub;

altfp_16int2fp int2fpconv_inst3 (.dataa(OFFSET), .clock(clk), .result(fp_X_OFFSET)); // to floating point

//compensate gain. 7 clks
//assign A_comp = A_in;
altfp_mul mul_inst1 (.dataa(A_fp), .datab(A_scale), .clock(clk), .result(A_comp) ); // Multiply by 1 to avoid clock skew. This could be done by adding a 7 clk delay?
altfp_mul mul_inst2 (.dataa(B_fp), .datab(B_scale), .clock(clk), .result(B_comp) ); // ajust gain. This could be done in fixed point.

// delata sigma, 7 clks
altfp_sub sub_inst1 (.dataa(A_comp), .datab(B_comp), .clock(clk), .result(delta), .zero() ); // Delta. 7 clks
altfp_add add_inst1 (.dataa(A_comp), .datab(B_comp), .clock(clk), .result(sigma), .zero(sigma_zero) );// Sigma. 7 clks

// division, 14 clks
altfp_div3232 div_inst2 (.dataa(delta), . datab(sigma_div), .clock(clk), .result(C));   //C = (A-B)/(A+B). 14 clks

altfp_mul mul_inst3 (.dataa(FP_KXY), .datab(scale), .clock(clk), .result(Kxy) ); //  

// scale. 7 clks
altfp_mul mul_inst4 (.dataa(Kxy), .datab(C), .clock(clk), .result(D) ); //D is position value in mm   

//adjust offset. 7 clks
altfp_mul mul_inst5 (.dataa(fp_X_OFFSET), .datab(fpdot001), .clock(clk), .result(fpOFFSETmm) );  //um to mm
altfp_add add_inst2(.dataa(D), .datab(fpOFFSETmm), .clock(clk), .result(fp_pos_mm) );// fp position in mm

// Tc = tao*T = [-1/ln(K2)] * T
// tao = 1/(2Pi*Fc), Fc: 3dB BW of the LPF

// for T = 400 ns,i.e. data rate: 2.5 MHz, decimated signal:

// K2 = 0.9, Tc = [-1/ln(0.951)] * 400ns = 7.961 us; Fc = 20 KHz
// K2 = 0.99, Tc = [-1/ln(0.995)] * 400ns = 40 us; Fc= 3.9 KHz
// K2 = 0.999, Tc = [-1/ln(0.999)] * 400ns = 400 us; 0.4 KHz
// K2 = 0.9995, Tc = [-1/ln(0.999)] * 400ns = 800 us; 0.2 KHz

// LPF. 22 clks
LPF_IIR LPF_output_inst0( 
    .FCLK(clk),
    .in_valid(LPF_en), //
	 .data_in(fp_pos_mm), //
	 .K2(IIR_OUT_K2),
    .data_out(fp_pos_mm_LPF) //
    );


endmodule

		