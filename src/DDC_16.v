`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//DDC_16: 16 bit integer version
// input: ADC signal, clk, 
// output: Amp, dclk, 
// by: Shengli Liu, Diagnostics, TRIUMF
// Histroy: Created on Feb. 14,2023

//////////////////////////////////////////////////////////////////////////////////

module DDC_16(
	input signed [DATA_WIDTH-1:0] din_0, 
	input signed [DATA_WIDTH-1:0] din_1, 
	input signed [DATA_WIDTH-1:0] din_2, 
	input signed [DATA_WIDTH-1:0] din_3, 
	
	input clk,  //20 MHz 
	input rst,
  	
	output d_clk, //clk for decimated data
	output clken, //for decimated data
	output [DATA_WIDTH-1:0] error, 
	output [FULL_WIDTH-1:0] Amplitude  //waveform
	
    );
	 
parameter DATA_WIDTH = 16;
parameter FULL_WIDTH = 64;


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

//NCO core created with clk=20 MHz, output freq = 5.0 MHz, 16 bit resolution.
//s(nT) = A sin[2πf0*nT + ϕ DITH )], A = 2^16
parameter PHI_INC_I = 1073741824; //from IP generation result 

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
		//ch2_data_I <= din_2*fcos; ch2_data_Q <= din_2*fsin;
		//ch3_data_I <= din_3*fcos; ch3_data_Q <= din_3*fsin;
	end

//-------------------------------------------------------------------------
// CIC filter/decimation
// N=3 (3 stages), M=1, R=8 (decimating ratio)

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
/*
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

CIC35 ch2_CIC_I(
			.clk(clk),
			.rst(rst),
			.d_in(ch2_data_I),
			.d_out(ch2_Iout),
			.d_clk());
			
CIC35 ch2_CIC_Q(
			.clk(clk),
			.rst(rst),
			.d_in(ch2_data_Q),
			.d_out(ch2_Qout),
			.d_clk());

CIC35 ch3_CIC_I(
			.clk(clk),
			.rst(rst),
			.d_in(ch3_data_I),
			.d_out(ch3_Iout),
			.d_clk());
			
CIC35 ch3_CIC_Q(
			.clk(clk),
			.rst(rst),
			.d_in(ch3_data_Q),
			.d_out(ch3_Qout),
			.d_clk());

*/
						
reg [63:0] ch0_sqsum,ch1_sqsum,ch2_sqsum,ch3_sqsum/*synthesis keep*/;
always @ (posedge clk) 
	begin
		ch0_sqsum <= ch0_Iout*ch0_Iout + ch0_Qout*ch0_Qout; 
		ch1_sqsum <= ch1_Iout*ch1_Iout + ch1_Qout*ch1_Qout; 
		//ch2_sqsum <= ch2_Iout*ch2_Iout + ch2_Qout*ch2_Qout; 
		//ch3_sqsum <= ch3_Iout*ch3_Iout + ch3_Qout*ch3_Qout;
	end
	

wire [DATA_WIDTH-1:0] ch0_sqrt,ch1_sqrt,ch2_sqrt,ch3_sqrt/*synthesis keep*/;
//wire [16:0] ch0_remain,ch1_remain,ch2_remain,ch3_remain/*synthesis keep*/;
//reg [DATA_WIDTH-1:0] ch0_Amp33,ch1_Amp33,ch2_Amp33,ch3_Amp33/*synthesis keep*/;
reg [DATA_WIDTH-1:0] ch0_Amp,ch1_Amp,ch2_Amp,ch3_Amp/*synthesis keep*/;

//left shit radicant to keep more significant digits in result due to the fact
//that result does not affect position calculation, it's just a constant multiplication.

alt_sqrt sqrt_inst0 ( .radical(ch0_sqsum << 12), .q(ch0_sqrt), .remainder() );
alt_sqrt sqrt_inst1 ( .radical(ch1_sqsum << 12), .q(ch1_sqrt), .remainder() );
//alt_sqrt sqrt_inst2 ( .radical(ch2_sqsum), .clk(clk), .q(ch2_sqrt), .remainder(ch2_remain) );
//alt_sqrt sqrt_inst3 ( .radical(ch3_sqsum), .clk(clk), .q(ch3_sqrt), .remainder(ch3_remain) );


always @ (posedge clk) 
	begin
	   ch0_Amp <= ch0_sqrt; 
		ch1_Amp <= ch1_sqrt; 
		
		//ch0_Amp33 <= {ch0_sqrt,17'b0} + ch0_remain; 
		//ch1_Amp33 <= {ch1_sqrt,17'b0} + ch1_remain; 
		//ch2_Amp33 <= {ch2_sqrt,17'b0} + ch2_remain; 
		//ch3_Amp33 <= {ch3_sqrt,17'b0} + ch3_remain; 
	end
	

//the reason to keep the result to be 16 bit is due to the fact that the 8 MSB of the sum are
//alwasy zero, so we get rid of the 8 MSB;
//the reason to divide by 2**8, is we might not need too many digits after decimal point.
//assign ch0_Amp = ch0_Amp33[24:9];
//assign ch1_Amp = ch1_Amp33[24:9];
//assign ch2_Amp = ch2_Amp33[24:9];
//assign ch3_Amp = ch3_Amp33[24:9];

//----------------------------------------------------------------------

//assign Amplitude = {ch3_Amp,ch2_Amp,ch1_Amp,ch0_Amp};

assign error = 16'b0;

endmodule

		