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
module calculate_position #(parameter SF_WIDTH = 32, parameter DATA_WIDTH = 16)
	(
   
	input [SF_WIDTH-1:0] A_amp, //fp 32 bit, amplitude signal 
	input [SF_WIDTH-1:0] B_amp,
	input data_valid, //not used
	
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
	output clk_slow2,
	output [SF_WIDTH-1:0] A_comp,
	output [SF_WIDTH-1:0] B_comp,
	
	output [SF_WIDTH-1:0] A_max,
	output [SF_WIDTH-1:0] B_max,
	output [SF_WIDTH-1:0] A_min,
	output [SF_WIDTH-1:0] B_min,
	
	output signed [SF_WIDTH-1:0] fp_pos_um_LPF, //fp_pos_um_LPF,
	output signed [SF_WIDTH-1:0] fp_pos_slow//fp_pos_slow // changed
	
    );
	 
//parameter SF_WIDTH = 32; 
//parameter DATA_WIDTH = 16;
parameter SUM_WIDTH = 32; 

parameter fp1 = 32'H3f800000; //1
parameter fp100 = 32'H42c80000; //100
parameter fp_neg100 = 32'Hc2c80000; //-100
parameter fpdot001 = 32'H3a83126f; //0.001
parameter fpdot2 = 32'H3e4ccccd; // = 1/5 = 0.2

reg [SF_WIDTH-1:0] A_in, B_in/*synthesis keep*/;
wire [SF_WIDTH-1:0] fp_X_OFFSET, Kxy,delta, sigma;
wire [SF_WIDTH-1:0] A,B,C,D,fpOFFSETmm,fp_pos_dac,fp_pos_um/*synthesis keep*/;
wire sigma_zero;
wire [SF_WIDTH-1:0] sigma_div = sigma_zero? fp1 : sigma;

reg [SF_WIDTH-1:0] A_scale,B_scale; // calibration values for each channel
reg [SF_WIDTH-1:0] scale;
 
always @ (posedge clk_fast) begin
		scale <= fp100; // new NOV 4
		
		if (gate && !dead_zone) begin 
//			A_scale <= fp1;
//			B_scale <= FP_CH2_NF;
			
	
//			A_in <= A_amp;
//			B_in <= B_amp; 	
			
			// reverse sign when inputs are swapped
			// delay not accounted for. May cause glitching/noise.
			if(flip_sign) begin
			   A_in <= B_amp;
				B_in <= A_amp;
				A_scale <= FP_CH2_NF;
				B_scale <= fp1;
				//scale <= fp_neg100; 
				
			end
			else begin
				A_in <= A_amp;
				B_in <= B_amp;
				A_scale <= fp1;
				B_scale <= FP_CH2_NF;
				//scale <= fp100;
			end
		end			
	end

// create integer version of position
wire signed [31:0] pos_slow1, pos_fast, pos_slow2;
//wire signed [31:0] fp_pos_um_LPF, fp_pos_slow;
wire clk_slow1;
altfp_fp2int32 fp2int_inst1(.dataa(fp_pos_um_LPF),.clock(clk_fast),.result(pos_fast));

// decimate and filter integer position
//CIC38 CIC(
//			.clk(clk_fast),
//			.rst(rst),
//			.d_in(pos_fast),
//			.d_out(pos_slow),
//			.clk_en(),
//			.d_clk(clk_slow));
//			
			
			
CIC #(
  .width(47) // 32 bits + 15 bits of growth
) cic_1 (
  .clk(clk_fast),
  .rst(0),
  .decimation_ratio(8),
  .d_in(pos_fast),
  .d_out(pos_slow1),
  .d_clk(clk_slow1)
);

CIC #(
  .width(47) // 32 bits + 15 bits of growth
) cic_2 (
  .clk(clk_slow1),
  .rst(0),
  .decimation_ratio(8),
  .d_in(pos_slow1),
  .d_out(pos_slow2),
  .d_clk(clk_slow2)
);

// replace this with CIC from Halo. Reduce from 2.5 MHz --> 50 kHz (50x decimation with 5x, 10x)
// load this into a 128 word RAM in the main block.

// 51 kHz (2.5 MHz decimated by 49)
altfp_32int2fp int2fpconv_inst1 (.dataa(pos_slow2), .clock(clk_slow2), .result(fp_pos_slow)); 
wire [SF_WIDTH-1:0] A_fp, B_fp;
//wire clk = decimate? clk_slow: clk_fast;

assign A_fp = A_in;
assign B_fp = B_in;
 
Maxmin maxmin_inst(
	.din_a(A_fp),
	.din_b(B_fp),
	.clk(clk_fast),
	.rst(rst),
	
	.max_A(A_max),
	.min_A(A_min),
	.max_B(B_max),
   .min_B(B_min)
    );	

wire [SF_WIDTH-1:0] A_sub, B_sub;

altfp_16int2fp int2fpconv_inst3 (.dataa(OFFSET), .clock(clk_fast), .result(fp_X_OFFSET)); // to floating point

//compensate gain. 7 clks
//assign A_comp = A_in;
altfp_mul mul_inst1 (.dataa(A_fp), .datab(A_scale), .clock(clk_fast), .result(A_comp) ); // Multiply by 1 to avoid clock skew. This could be done by adding a 7 clk delay?
altfp_mul mul_inst2 (.dataa(B_fp), .datab(B_scale), .clock(clk_fast), .result(B_comp) ); // ajust gain. This could be done in fixed point.

// delata sigma, 7 clks
altfp_sub sub_inst1 (.dataa(A_comp), .datab(B_comp), .clock(clk_fast), .result(delta), .zero() ); // Delta. 7 clks
altfp_add add_inst1 (.dataa(A_comp), .datab(B_comp), .clock(clk_fast), .result(sigma), .zero(sigma_zero) );// Sigma. 7 clks

// division, 14 clks
altfp_div3232 div_inst2 (.dataa(delta), . datab(sigma_div), .clock(clk_fast), .result(C));   //C = (A-B)/(A+B). 14 clks

altfp_mul mul_inst3 (.dataa(FP_KXY), .datab(scale), .clock(clk_fast), .result(Kxy) ); //  

// scale. 7 clks
altfp_mul mul_inst4 (.dataa(Kxy), .datab(C), .clock(clk_fast), .result(D) ); //D is position value in um   

//adjust offset. 7 clks
//altfp_mul mul_inst5 (.dataa(fp_X_OFFSET), .datab(fpdot001), .clock(clk_fast), .result(fpOFFSETmm) );  //um to mm
altfp_add add_inst2(.dataa(D), .datab(fp_X_OFFSET), .clock(clk_fast), .result(fp_pos_um) );// fp position in um

// Tc = tao*T = [-1/ln(K2)] * T
// tao = 1/(2Pi*Fc), Fc: 3dB BW of the LPF

// for T = 400 ns,i.e. data rate: 2.5 MHz, decimated signal:

// K2 = 0.9, Tc = [-1/ln(0.951)] * 400ns = 7.961 us; Fc = 20 KHz
// K2 = 0.99, Tc = [-1/ln(0.995)] * 400ns = 40 us; Fc= 3.9 KHz
// K2 = 0.999, Tc = [-1/ln(0.999)] * 400ns = 400 us; 0.4 KHz
// K2 = 0.9995, Tc = [-1/ln(0.999)] * 400ns = 800 us; 0.2 KHz

// LPF. 22 clks
LPF_IIR LPF_output_inst0( 
    .FCLK(clk_fast),
    .in_valid(LPF_en), //
	 .data_in(fp_pos_um), //
	 .K2(IIR_OUT_K2),
    .data_out(fp_pos_um_LPF) //
    );


endmodule

		