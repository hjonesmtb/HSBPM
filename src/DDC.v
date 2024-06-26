`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//DDC: Digital Down Conversion 
// input: ADC signal, clk, 
// output: Amp, dclk, 
// by: Shengli Liu, Diagnostics, TRIUMF
// Histroy: Created on Feb. 14,2023

//////////////////////////////////////////////////////////////////////////////////

module DDC(
	input signed [DATA_WIDTH-1:0] din_0, 
	input signed [DATA_WIDTH-1:0] din_1, 
	input signed [DATA_WIDTH-1:0] din_2, 
	input signed [DATA_WIDTH-1:0] din_3, 
	
	input in_valid,
	input ena_comb,
	
	input clk,  //20 MHz 
	input rst,
  	
	output d_clk, //clk for decimated data
	output clken, //for decimated data
	output [DATA_WIDTH-1:0] error, 
	output [SF_WIDTH-1:0] fp_ch1_Amp,   //32 bit (floating point), decimated amplitude signals
	output [SF_WIDTH-1:0] fp_ch2_Amp, 
	output [SF_WIDTH-1:0] fp_ch3_Amp, 
	output [SF_WIDTH-1:0] fp_ch4_Amp 
	
    );
	 
parameter FP_5000 = 32'H459c4000; 
parameter FP_0002 = 32'h3951b717; // 1/5000
parameter FP_neg0002 = 32'hb951b717; // -1/5000

//-------------------------------------------------------------------------
//Poor man's NCO: not good, position calculated drifts..., March 3,2023
//NCO: frequency to be Fs/4, see design note, Fs is chosen to make this OK.

/*
reg [1:0] cnt;
reg signed [DATA_WIDTH-1:0] data_I,data_Q;

always @ (posedge clk) cnt <= cnt + 1; 
always @ (posedge clk) 
		case (cnt)
				0:	begin data_I <= din;   data_Q <= 16'b0; end
				1:	begin data_I <= 16'b0; data_Q <= din; end
				2:	begin data_I <= -din;  data_Q <= 16'b0; end
				3:	begin data_I <= 16'b0; data_Q <= -din; end
				
		endcase
*/

//---------------------------------------------------------------------------
//Rich man's NCO
wire signed [DATA_WIDTH-1:0] fcos,fsin /*synthesis keep*/;
reg signed [31:0] ch0_data_I,ch0_data_Q /*synthesis keep*/;
reg signed [31:0] ch1_data_I,ch1_data_Q /*synthesis keep*/;
reg signed [31:0] ch2_data_I,ch2_data_Q /*synthesis keep*/;
reg signed [31:0] ch3_data_I,ch3_data_Q /*synthesis keep*/;

wire signed [31:0] ch0_Iout,ch1_Iout,ch2_Iout,ch3_Iout/*synthesis keep*/;  
wire signed [31:0] ch0_Qout,ch1_Qout,ch2_Qout,ch3_Qout/*synthesis keep*/;   

//NCO core created with clk=20 MHz, output freq = 6.1 MHz, 16 bit resolution.
//s(nT) = A sin[2πf0*nT + ϕ DITH )], A = 2^16
parameter PHI_INC_I = 1309965025; //from IP generation result 

NCO NOC_inst (
			.clk(clk),
			.clken(1'b1),
			.reset_n(~rst),
			.phi_inc_i(PHI_INC_I),
			.fcos_o(fcos),
			.fsin_o(fsin),
			.out_valid());	
			
always @ (posedge clk) 
	begin
		ch0_data_I <= din_0*fcos; ch0_data_Q <= din_0*fsin;
		ch1_data_I <= din_1*fcos; ch1_data_Q <= din_1*fsin;
		ch2_data_I <= din_2*fcos; ch2_data_Q <= din_2*fsin;
		ch3_data_I <= din_3*fcos; ch3_data_Q <= din_3*fsin;
	end

//-------------------------------------------------------------------------
// CIC filter/decimation
// N=3 (3 stages), M=1, R=8 (decimating ratio) 
// N=5 (5 stages), M=1, R=8 (decimating ratio)

CIC38 ch0_CIC_I(
			.clk(clk),
			.rst(rst),
			.d_in(ch0_data_I),
			.d_out(ch0_Iout),
			.clk_en(clken),
			.d_clk(d_clk));

CIC38 ch0_CIC_Q(
			.clk(clk),
			.rst(rst),
			.d_in(ch0_data_Q),
			.d_out(ch0_Qout),
			.d_clk());

CIC38 ch1_CIC_I(
			.clk(clk),
			.rst(rst),
			.d_in(ch1_data_I),
			.d_out(ch1_Iout),
			.d_clk());
			
CIC38 ch1_CIC_Q(
			.clk(clk),
			.rst(rst),
			.d_in(ch1_data_Q),
			.d_out(ch1_Qout),
			.d_clk());

CIC38 ch2_CIC_I(
			.clk(clk),
			.rst(rst),
			.d_in(ch2_data_I),
			.d_out(ch2_Iout),
			.d_clk());
			
CIC38 ch2_CIC_Q(
			.clk(clk),
			.rst(rst),
			.d_in(ch2_data_Q),
			.d_out(ch2_Qout),
			.d_clk());

CIC38 ch3_CIC_I(
			.clk(clk),
			.rst(rst),
			.d_in(ch3_data_I),
			.d_out(ch3_Iout),
			.d_clk());
			
CIC38 ch3_CIC_Q(
			.clk(clk),
			.rst(rst),
			.d_in(ch3_data_Q),
			.d_out(ch3_Qout),
			.d_clk());
			
//wire signed [31:0] ch0_Icomp,ch1_Icomp,ch2_Icomp,ch3_Icomp/*synthesis keep*/;  
//wire signed [31:0] ch0_Qcomp,ch1_Qcomp,ch2_Qcomp,ch3_Qcomp/*synthesis keep*/; 
			
//FIR_comp comp_0_I(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch0_Iout), // 32 bit CIC data
//	.data_out(ch0_Icomp)
//    );
//	 
//FIR_comp comp_0_Q(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch0_Qout), // 32 bit CIC data
//	.data_out(ch0_Qcomp)
//    );
//	 
//FIR_comp comp_1_I(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch1_Iout), // 32 bit CIC data
//	.data_out(ch1_Icomp)
//    );
//	 
//FIR_comp comp_1_Q(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch1_Qout), // 32 bit CIC data
//	.data_out(ch1_Qcomp)
//    );
//	 
//FIR_comp comp_2_I(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch2_Iout), // 32 bit CIC data
//	.data_out(ch2_Icomp)
//    );
//	 
//FIR_comp comp_2_Q(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch2_Qout), // 32 bit CIC data
//	.data_out(ch2_Qcomp)
//    );
//	 
//FIR_comp comp_3_I(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch3_Iout), // 32 bit CIC data
//	.data_out(ch3_Icomp)
//    );
//	 
//FIR_comp comp_3_Q(
//	.clk(d_clk), // 2.5 MHz
//	.reset(rst),
//	.data_in(ch3_Qout), // 32 bit CIC data
//	.data_out(ch3_Qcomp)
//    );
				
reg [63:0] ch0_sqsum,ch1_sqsum,ch2_sqsum,ch3_sqsum/*synthesis keep*/;

wire [SF_WIDTH-1:0] fp_ch0_sqsum,fp_ch1_sqsum,fp_ch2_sqsum,fp_ch3_sqsum/*synthesis keep*/;
wire [SF_WIDTH-1:0] fp_ch0_sqrt,fp_ch1_sqrt,fp_ch2_sqrt,fp_ch3_sqrt/*synthesis keep*/;

wire overflow0, nan0/*synthesis keep*/;
wire overflow1, nan1/*synthesis keep*/;
wire overflow2, nan2/*synthesis keep*/;
wire overflow3, nan3/*synthesis keep*/;

always @ (posedge clk) 
	begin
		ch0_sqsum <= ch0_Iout*ch0_Iout + ch0_Qout*ch0_Qout; 
		ch1_sqsum <= ch1_Iout*ch1_Iout + ch1_Qout*ch1_Qout; 
		ch2_sqsum <= ch2_Iout*ch2_Iout + ch2_Qout*ch2_Qout; 
		ch3_sqsum <= ch3_Iout*ch3_Iout + ch3_Qout*ch3_Qout;
	end

altfp_64int2fp conv_inst0(.dataa(ch0_sqsum), .clock(clk), .result(fp_ch0_sqsum));
altfp_64int2fp conv_inst1(.dataa(ch1_sqsum), .clock(clk), .result(fp_ch1_sqsum));
altfp_64int2fp conv_inst2(.dataa(ch2_sqsum), .clock(clk), .result(fp_ch2_sqsum));
altfp_64int2fp conv_inst3(.dataa(ch3_sqsum), .clock(clk), .result(fp_ch3_sqsum));

altfp_sqrt sqrt_inst0(.data(fp_ch0_sqsum), .clock(clk), .result(fp_ch0_sqrt), .overflow(of0), .nan(nan0));
altfp_sqrt sqrt_inst1(.data(fp_ch1_sqsum), .clock(clk), .result(fp_ch1_sqrt), .overflow(of1), .nan(nan1));
altfp_sqrt sqrt_inst2(.data(fp_ch2_sqsum), .clock(clk), .result(fp_ch2_sqrt), .overflow(of2), .nan(nan2));
altfp_sqrt sqrt_inst3(.data(fp_ch3_sqsum), .clock(clk), .result(fp_ch3_sqrt), .overflow(of3), .nan(nan3));


assign error = {14'b0,of0|of1|of2|of3,nan0|nan1|nan2|nan3};

reg [SF_WIDTH-1:0] fp_ch0,fp_ch1,fp_ch2,fp_ch3/*synthesis keep*/;
	
always @ (posedge clk) 
	begin
	   fp_ch0 <= fp_ch0_sqrt; 
		fp_ch1 <= fp_ch1_sqrt; 
		fp_ch2 <= fp_ch2_sqrt; 
		fp_ch3 <= fp_ch3_sqrt; 				
	end

wire [SF_WIDTH-1:0] fp_ch1_comb, fp_ch2_comb, fp_ch3_comb, fp_ch4_comb;
wire [SF_WIDTH-1:0] fp_ch1_scale, fp_ch2_scale, fp_ch3_scale, fp_ch4_scale;
	
combfilter comb_inst1(
    .clk(clk), // 20 MHz SCLK
    .in_valid(in_valid),   // 1.153 MHz pulse. Pulse should be between 50 ns and 100ns wide.
    .rst(),
	 	 
    .data_in(fp_ch0), //input data 
    .data_out(fp_ch1_comb), //output data
	 .overflow() //calculation overflow 
	);

combfilter comb_inst2(
    .clk(clk), // 20 MHz SCLK
    .in_valid(in_valid),   // 1.153 MHz pulse. Pulse should be between 50 ns and 100ns wide.
    .rst(),
	 	 
    .data_in(fp_ch1), //input data 
    .data_out(fp_ch2_comb), //output data
	 .overflow() //calculation overflow 
	);
	
combfilter comb_inst3(
    .clk(clk), // 20 MHz SCLK
    .in_valid(in_valid),   // 1.153 MHz pulse. Pulse should be between 50 ns and 100ns wide.
    .rst(),
	 	 
    .data_in(fp_ch2), //input data 
    .data_out(fp_ch3_comb), //output data
	 .overflow() //calculation overflow 
	);
	
combfilter comb_inst4(
    .clk(clk), // 20 MHz SCLK
    .in_valid(in_valid),   // 1.153 MHz pulse. Pulse should be between 50 ns and 100ns wide.
    .rst(),
	 	 
    .data_in(fp_ch3), //input data 
    .data_out(fp_ch4_comb), //output data
	 .overflow() //calculation overflow 
	);
	
assign fp_ch1_Amp = ena_comb? fp_ch1_comb : fp_ch1_scale;
assign fp_ch2_Amp = ena_comb? fp_ch2_comb : fp_ch2_scale;
assign fp_ch3_Amp = ena_comb? fp_ch3_comb : fp_ch3_scale;
assign fp_ch4_Amp = ena_comb? fp_ch4_comb : fp_ch4_scale;


altfp_mul mul_inst0 (.dataa(fp_ch0), .datab(FP_0002), .clock(clk), .result(fp_ch1_scale) );
altfp_mul mul_inst1 (.dataa(fp_ch1), .datab(FP_0002), .clock(clk), .result(fp_ch2_scale) );
altfp_mul mul_inst2 (.dataa(fp_ch2), .datab(FP_0002), .clock(clk), .result(fp_ch3_scale) );
altfp_mul mul_inst3 (.dataa(fp_ch3), .datab(FP_0002), .clock(clk), .result(fp_ch4_scale) );

endmodule
