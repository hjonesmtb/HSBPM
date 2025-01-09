/*
4 point, unsigned running average.
Delays input signal by 6 clks.
*/

module boxfilter_4 (
    input [63:0] signal,  // 16-bit input signal
    input clk,    
    output reg [63:0] avg      // running 4 point average
);

    reg [63:0] signal_1, signal_2, signal_3, signal_4;
	 reg [63:0] signal_5, signal_6, signal_7, signal_8;
	 reg [66:0] avg_65; // to hold accumualated sum

    // Always block to update sums and count while gate is high
    always @(posedge clk) begin
		signal_1 <= signal;
		signal_2 <= signal_1;
		signal_3 <= signal_2;
		signal_4 <= signal_3;
		signal_5 <= signal_4;
		signal_6 <= signal_5;
		signal_7 <= signal_6;
		signal_8 <= signal_7;
		avg_65 <= (signal_1 + signal_2 + signal_3 + signal_4 + signal_5 + signal_6 + signal_7 + signal_8) >> 3;

		avg <= avg_65;
     
    end

endmodule
