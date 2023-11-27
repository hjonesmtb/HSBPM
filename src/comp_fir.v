`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Description: 
// COMP_FIR: 
// by: Shengli Liu, Diagnostics, TRIUMF
// Histroy: Created on March 31,2023

// last modified:
// 

module COMP_FIR(
   input clk,
   input in_valid,   
	input [31:0] data_in, 
   output  [31:0] data_out
    );
 
parameter  SF_WIDTH = 32;

//8 taps moving average FIR filter: 
//Y[n] = {X[n] + X[n-1] + X[n-2]...+X[n-7]}/8;

parameter K = 32'H3e000000; //0.125

wire [SF_WIDTH-1:0] X,Y;
wire [SF_WIDTH-1:0] S1,S2,S3,S4,S5,S6,S7,S8;
reg [SF_WIDTH-1:0] X1,X2,X3,X4,X5,X6,X7,Y1/*synthesis keep*/;

wire NaN/*synthesis keep*/;

assign X = data_in;
assign data_out = Y1;

altfp_add add_inst0 (.dataa(X),  .datab(X1), .clock(clk), .result(S1), .nan(NaN)); 
altfp_add add_inst1 (.dataa(S1), .datab(X2), .clock(clk), .result(S2)); 
altfp_add add_inst2 (.dataa(S2), .datab(X3), .clock(clk), .result(S3)); 
altfp_add add_inst3 (.dataa(S3), .datab(X4), .clock(clk), .result(S4)); 
altfp_add add_inst4 (.dataa(S4), .datab(X5), .clock(clk), .result(S5)); 
altfp_add add_inst5 (.dataa(S5), .datab(X6), .clock(clk), .result(S6)); 
altfp_add add_inst6 (.dataa(S6), .datab(X7), .clock(clk), .result(S7)); 

 
altfp_mul mul_inst1 (.dataa(S7), .datab(K), .clock(clk), .result(Y) );   



always @(posedge clk)  
  if (in_valid) 
     begin 
        if (NaN) begin X1 <= 32'b0; X2 <= 32'b0; end
	     else 
		    begin X1 <= X; 
					 X2 <= X1; 
					 X3 <= X2; 
					 X4 <= X3; 
					 X5 <= X4;
					 X6 <= X5; 
					 X7 <= X6; 
					 Y1 <= Y; end
     end
	  
endmodule