`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// calcualte X, Y postion 
// 
// by: Shengli Liu, Diagnostics, TRIUMF
// History: Created on March 1, 2021
// Aug. 4,2021: changed the input of LPF to the value which is before converted to DAC value, hoping to 
//    solve the overflow issue of the LPF.

//	by: Yuhai Li, Diagnostics Coop Student, TRIUMF
//	Jan. 18,2022: changed peak calculation algorithm to a signal energy calculation algorithm to improve
//		algorithm response to very small and very large beam duty cycles.
//
//////////////////////////////////////////////////////////////////////////////////

// ~78 clk latency = 31 us
module calculate_position(
   
	input [SF_WIDTH-1:0] A_amp, //fp 32 bit, amplitude signal 
	input [SF_WIDTH-1:0] B_amp,
	input data_valid, //new data, one clk pulse
	
	input [DATA_WIDTH-1:0] OFFSET,//offset adjust, um
	input [SF_WIDTH-1:0] FP_CH0_NF, //gain compensation, around 1.0, 
	input [SF_WIDTH-1:0] FP_CH1_NF,
	
	input [SF_WIDTH-1:0] FP_KXY, //= Kx, Ky, BPM sensitivity
	input [1:0] AVG_select, //select AVG time for peak calculating
	input clk,  //decimated clk: 2.5 MHz 
	input rst,
	input gate, 
   	
	//input [SF_WIDTH-1:0] K1, //
	input [SF_WIDTH-1:0] IIR_OUT_K2, //LPF K2, fp
	input [DATA_WIDTH-1:0] CH0_ADC_OFFSET,//offset adjust, ADC counts (HJ Nov 27,2023)
	input [DATA_WIDTH-1:0] CH1_ADC_OFFSET,//offset adjust, ADC counts (HJ Nov 27,2023)
	input cal_sel,
	input clk_10Hz,
	output [SF_WIDTH-1:0] A_comp,
	output [SF_WIDTH-1:0] B_comp,
	
	output [SF_WIDTH-1:0] A_max,
	output [SF_WIDTH-1:0] B_max,
	output [SF_WIDTH-1:0] A_min,
	output [SF_WIDTH-1:0] B_min,
	
	output [SF_WIDTH-1:0] fp_pos_mm_LPF,
	output [SF_WIDTH-1:0] fp_pos_mm_cal // changed
	
    );
	 
parameter SF_WIDTH = 32; 
parameter DATA_WIDTH = 16;
parameter SUM_WIDTH = 32; 

parameter fp1 = 32'H3f800000; //1
parameter fp100 = 32'H42c80000; //100
parameter fpdot001 = 32'H3a83126f; //0.001

reg [SF_WIDTH-1:0] ch0_Amp, ch1_Amp/*synthesis keep*/;
wire [SF_WIDTH-1:0] fp_X_OFFSET, fpCH0_OFFSET, fpCH1_OFFSET, Kxy,delta, sigma;
wire [SF_WIDTH-1:0] A,B,C,D,fpOFFSETmm,fp_pos_dac,fp_pos_mm/*synthesis keep*/;
wire sigma_zero;
wire [SF_WIDTH-1:0] sigma_div = sigma_zero? fp1 : sigma;

wire [SF_WIDTH-1:0] A_gained, B_gained;

reg [SF_WIDTH-1:0] A_scale, B_scale; // calibration values for each channel

reg [SF_WIDTH-1:0] X_cal;

always @ (posedge clk) 
	begin
		if(rst) begin
			A_scale <= FP_CH0_NF;
			B_scale <= FP_CH1_NF;	
		end
		else begin
			if (gate) begin 
				ch0_Amp <= A_amp;
				ch1_Amp <= B_amp; 
			end		

			if(cal_sel) begin
				if(clk_10Hz) begin
					X_cal <= fp_pos_mm_LPF;
					A_scale <= FP_CH0_NF;
					B_scale <= FP_CH1_NF;	
				end
			end
			else begin
				X_cal <= 0;
				A_scale <= FP_CH0_NF;
				B_scale <= FP_CH1_NF;
			end
		end
		
	end

Maxmin maxmin_inst(
	.din_a(ch0_Amp),
	.din_b(ch1_Amp),
	.clk(clk),
	.rst(rst),
	
	.max_A(A_max),
	.min_A(A_min),
	.max_B(B_max),
   .min_B(B_min)
    );	


//altfp_16int2fp int2fpconv_inst1 (.dataa(avg_A), .clock(clk), .result(A)); // to floating point
//altfp_16int2fp int2fpconv_inst2 (.dataa(avg_B), .clock(clk), .result(B)); // to floating point


altfp_16int2fp int2fpconv_inst3 (.dataa(OFFSET), .clock(clk), .result(fp_X_OFFSET)); // to floating point


altfp_16int2fp int2fpconv_inst4 (.dataa(CH0_ADC_OFFSET), .clock(clk), .result(fpCH0_OFFSET)); // to floating point
altfp_16int2fp int2fpconv_inst5 (.dataa(CH1_ADC_OFFSET), .clock(clk), .result(fpCH1_OFFSET)); // to floating point

//compensate gain. 7 clks
altfp_mul mul_inst2 (.dataa(ch0_Amp), .datab(A_scale), .clock(clk), .result(A_gained) ); // ajust gain. This could be done in fixed point.
altfp_mul mul_inst3 (.dataa(ch1_Amp), .datab(B_scale), .clock(clk), .result(B_gained) ); //  

// offset. 7clks
altfp_add add_inst1 (.dataa(A_gained), .datab(fpCH0_OFFSET), .clock(clk), .result(A_comp));// offset. 7 clks
altfp_add add_inst2 (.dataa(B_gained), .datab(fpCH1_OFFSET), .clock(clk), .result(B_comp));// offset 7 clks

// delata sigma, 7 clks
altfp_sub sub_inst1 (.dataa(A_comp), .datab(B_comp), .clock(clk), .result(delta) ); // Delta. 7 clks
altfp_add add_inst3 (.dataa(A_comp), .datab(B_comp), .clock(clk), .result(sigma), .zero(sigma_zero) );// Sigma. 7 clks

// division, 14 clks
altfp_div3232 div_inst2 (.dataa(delta), . datab(sigma_div), .clock(clk), .result(C));   //C = (A-B)/(A+B). 14 clks

altfp_mul mul_inst4 (.dataa(FP_KXY), .datab(fp100), .clock(clk), .result(Kxy) ); //  

// scale. 7 clks
altfp_mul mul_inst5 (.dataa(Kxy), .datab(C), .clock(clk), .result(D) ); //D is position value in mm   

//adjust offset. 7 clks
altfp_mul mul_inst6 (.dataa(fp_X_OFFSET), .datab(fpdot001), .clock(clk), .result(fpOFFSETmm) );  //um to mm
altfp_add add_inst4(.dataa(D), .datab(fpOFFSETmm), .clock(clk), .result(fp_pos_mm) );// fp position in mm

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
    .in_valid(1'b1), //
	 .data_in(fp_pos_mm),
	 .K2(IIR_OUT_K2),
    .data_out(fp_pos_mm_LPF) //
    );
	 
// calibrate. 7 clks
altfp_sub sub_inst2 (.dataa(fp_pos_mm_LPF), .datab(X_cal), .clock(clk), .result(fp_pos_mm_cal) ); // calibration
 
endmodule

		