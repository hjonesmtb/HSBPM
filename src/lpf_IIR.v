`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: 
// LPF_IIR:  based on Bill R. lowpass5.bdf of UCN BPM Module 1012 processor
// by: Shengli Liu, Diagnostics, TRIUMF
// Histroy: Created on June 20,2019

// last modified: March 5,2021, SL
// changed fixed point coeff. to floating point: K1,K2
// I think the reason that Bill R's using the fixed point is it's easier to convert from real number.

// total latency ~22 clks
module LPF_IIR(
    input FCLK,
    input in_valid,   

	input [31:0] data_in,
	
	input [31:0] K2, //
	 
    output  [31:0] data_out

    );
 
parameter  SF_WIDTH = 32;

//info: 
//single pole IIR LPF: 

//first order IIR LPF: 
// difference equation: y[n] = (1-d)*x[n] + d*y[n-1]
// d is called decay factor
// d = e^(-1/tao), tao = 1/(2Pi*Fc); tao is called time constant, Fc is normalized 3dB
// frequency.
// T: sampling period
// tao*T is the time constant in second;
// fc = Fc/T is the 3dB frequnecy in Hz.

//-----------------------------------------------------
// ( March 4,2021,SL updated)
// Calculate the Tc (time constant in Second), BW: 
// The T sampling period is not necessary ADC rate, it depends on the rate of "in_valid";
// So T = 1 ms since the BPM trigger rate is 1 Khz:
// tao = -1/ln(K2), 
// Tc = tao*T = [-1/ln(K2)] * T ;
// fc = Fc/T = 1/(2Pi*Tc);
// for T = 1 ms, following is using this T:
// K2 = 0.1, Tc = [-1/ln(0.1)] * 1 = 0.434 ms; 
// K2 = 0.9, Tc = [-1/ln(0.9)] * 1 = 9.5 ms; 
// K2 = 0.99, Tc = [-1/ln(0.99)] * 1 = 100 ms; 
// K2 = 0.999, Tc = [-1/ln(0.999)] * 1 = 1000 ms; 
//---------------------------------------------------------


parameter fp1 = 32'H3f800000; //1

wire [SF_WIDTH-1:0] X,Y,XK,Y1K,K1/*synthesis keep*/;
reg [SF_WIDTH-1:0] Y1/*synthesis keep*/;

wire NaN;

assign X = data_in;
assign data_out = Y;

// 7 clks
altfp_sub sub_inst1 (.dataa(fp1), .datab(K2), .clock(FCLK), .result(K1) ); // K1 = 1 - K2

// 7 clks
altfp_mul mul_inst1 (.dataa(X), .datab(K1), .clock(FCLK), .result(XK) );   
altfp_mul mul_inst2 (.dataa(Y1), .datab(K2), .clock(FCLK), .result(Y1K) );    	 

// 7 clks
altfp_add add_inst1 (.dataa(XK), .datab(Y1K), .clock(FCLK), .result(Y), .nan(NaN) ); 

always @(posedge FCLK)  
  if (in_valid) 
     begin 
        if (NaN) Y1 <= 32'b0;
	     else Y1 <= Y;
     end
	  
endmodule