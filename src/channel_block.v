`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: 
// chanenl block: 
//	// by: Shengli Liu, Diagnostics, TRIUMF
/*
 * Modification history:
 * Apr 8 2024: added 6 clock cycle delay to fp_chx_Amp
 */
 
module channel_block(
 input clk,
 input DCLK,
 input SYS_RST,
 
 input [FULL_WIDTH-1:0] din,
 input trig,
 input in_valid, 
 input ena_comb,
 input [SF_WIDTH-1:0] alpha,// for comb filter
 
 //from fast fifo
 input fast_fifo_full,
 input fast_fifo_empty,
 
 input waveform_select, 
 
 //to fast fifo
 output [FULL_WIDTH-1:0] fast_fifo_din,
 output fast_fifo_wr,
 
 output [DATA_WIDTH-1:0] error,
 output d_clk, //clk for Amp, decimated, ~ 2.5 MHz, if R = 8
 
 output [DATA_WIDTH-1:0] Amp_avg,  // 16 bit int, Avg of 4 channel signal
 output reg [SF_WIDTH-1:0] fp_ch1_Amp, // FP format, Demodulated waveform , in same data rate as din
 output reg [SF_WIDTH-1:0] fp_ch2_Amp,
 output reg [SF_WIDTH-1:0] fp_ch3_Amp,
 output reg [SF_WIDTH-1:0] fp_ch4_Amp
);

reg [SF_WIDTH-1:0] fp_ch1, fp_ch2, fp_ch3, fp_ch4;

//-------Circular buffer and trigger ----------------------------
wire rd_C_buffer,event_rdy/*synthesis keep*/;
wire [FULL_WIDTH-1:0] CB_din;
wire [DATA_WIDTH-1:0] ch0,ch1,ch2,ch3/*synthesis keep*/;
wire [SF_WIDTH-1:0] fp_ch0_buf,fp_ch1_buf,fp_ch2_buf,fp_ch3_buf;
wire [FULL_WIDTH-1:0] Amp = {ch3,ch2,ch1,ch0};

wire of0, nan0;
wire of1, nan1;
wire of2, nan2;
wire of3, nan3;

//use 18 bit to prevent saturation of amp_sum signal:
//wire [DATA_WIDTH+1:0] Amp_sum  = ch0 + ch1 + ch2 + ch3 ;
//assign Amp_avg = Amp_sum[DATA_WIDTH+1:2]; //divided by 4
wire [DATA_WIDTH+1:0] Amp_sum  = ch0 + ch1 + ch2 + ch3; 
assign Amp_avg = Amp_sum[DATA_WIDTH+1:2]; //divided by 4

reg [SF_WIDTH-1:0] fp_ch1_delay [6:0];
reg [SF_WIDTH-1:0] fp_ch2_delay [6:0];
reg [SF_WIDTH-1:0] fp_ch3_delay [6:0];
reg [SF_WIDTH-1:0] fp_ch4_delay [6:0];

integer i;
// delay fp_chx_Amp signals by 6 clock cycles to keep in sync with Amp_avg
// replace this with moving avg of 4x
always @ (posedge DCLK)
    begin 
		fp_ch1_delay[0] <= fp_ch1;
		fp_ch2_delay[0] <= fp_ch2;
		fp_ch3_delay[0] <= fp_ch3;
		fp_ch4_delay[0] <= fp_ch4;
      for (i = 1; i<=4; i=i+1) begin
			fp_ch1_delay[i] <= fp_ch1_delay[i-1];
			fp_ch2_delay[i] <= fp_ch2_delay[i-1];
			fp_ch3_delay[i] <= fp_ch3_delay[i-1];
			fp_ch4_delay[i] <= fp_ch4_delay[i-1];
		end
		fp_ch1_Amp <= fp_ch1_delay[4];
		fp_ch2_Amp <= fp_ch2_delay[4];
		fp_ch3_Amp <= fp_ch3_delay[4];
		fp_ch4_Amp <= fp_ch4_delay[4];
	 end	

// This adds 6 clock cycles of latency between amp_avg and the signal output
altfp_fp2int conv_inst0(.dataa(fp_ch1),.clock(DCLK),.result(ch0), .overflow(of0), .nan(nan0));
altfp_fp2int conv_inst1(.dataa(fp_ch2),.clock(DCLK),.result(ch1), .overflow(of1), .nan(nan1));
altfp_fp2int conv_inst2(.dataa(fp_ch3),.clock(DCLK),.result(ch2), .overflow(of2), .nan(nan2));
altfp_fp2int conv_inst3(.dataa(fp_ch4),.clock(DCLK),.result(ch3), .overflow(of3), .nan(nan3));

assign CB_din = (waveform_select == 0)? din : 
					 (waveform_select == 1)? Amp : din;
					 
wire C_Buffer_clken, clken/*synthesis keep*/;			 
assign C_Buffer_clken = (waveform_select == 0)? 1'b1 : 
					         (waveform_select == 1)? clken : 1'b1;
Circular_Buffer C_Buffer(
 .DIN(CB_din), //64 bit
 .RST(SYS_RST),
 .TRIG(trig),
 .clk(clk),
 .clken(C_Buffer_clken), //from DDC 
 .RD(rd_C_buffer),
 .EVENT_RDY(event_rdy),
 .DOUT(fast_fifo_din) //64 bit, to fast fifo, for display in Labview
    );

//don't worry about the BLR_GAIN name, 
//this module transfer the signal waveform from the circular buffer into fast fifo
BLR_GAIN snap_inst(
		.RUN(1'b1),
		.rst(SYS_RST),
		.clk(clk),

      .fifo_full(fast_fifo_full),
		.fifo_empty(fast_fifo_empty),
		.event_rdy(event_rdy), // input from Circular buffer
		.rd(rd_C_buffer), // output, read Circular channel buffer 
		.wr(fast_fifo_wr), // output, write Fast fifo

		.busy(busy) // not in use, to prevent the Fast fifo to be readout by MB
	
	);	
//------ DDC ----------------------------

wire [DATA_WIDTH-1:0] DDC_error;
assign error = DDC_error | {14'b0,of0|of1|of2|of3,nan0|nan1|nan2|nan3};

// din -> DDC -> fp_ch -> ch (demodulated) -> Amp (demod. 2.5 MHz) 
DDC DDC_inst(
	.din_0(din[15:0]), //16 bit ADC value 
	.din_1(din[31:16]),//16 bit ADC value 
	.din_2(din[47:32]),//16 bit ADC value 
	.din_3(din[63:48]),//16 bit ADC value 
	
	.in_valid(in_valid),
	.ena_comb(ena_comb),
	
	.clk(clk),  //ADC clk, ~ 20.xxxx MHz. 
	.rst(SYS_RST),
	
	.d_clk(d_clk), //clk for output data
	.clken(clken), //for output data
	.error(DDC_error), 
	.fp_ch1_Amp(fp_ch0_buf), // Demodulated waveform , in same data rate as din
	.fp_ch2_Amp(fp_ch1_buf),
	.fp_ch3_Amp(fp_ch2_buf),
	.fp_ch4_Amp(fp_ch3_buf)
    );

	 //  1 clock
always @ (posedge DCLK) 
	begin
	   fp_ch1 <= fp_ch0_buf; 
		fp_ch2 <= fp_ch1_buf; 
		fp_ch3 <= fp_ch2_buf; 
		fp_ch4 <= fp_ch3_buf; 		
	end


//--------------------------------------------------------
// compensation FIR
/*
COMP_FIR fir_0(.clk(DCLK), .in_valid(1'b1), .data_in(fp_ch0_buf), .data_out(fp_ch1_Amp));
COMP_FIR fir_1(.clk(DCLK), .in_valid(1'b1), .data_in(fp_ch1_buf), .data_out(fp_ch2_Amp));
COMP_FIR fir_2(.clk(DCLK), .in_valid(1'b1), .data_in(fp_ch2_buf), .data_out(fp_ch3_Amp));
COMP_FIR fir_3(.clk(DCLK), .in_valid(1'b1), .data_in(fp_ch3_buf), .data_out(fp_ch4_Amp));
*/
endmodule