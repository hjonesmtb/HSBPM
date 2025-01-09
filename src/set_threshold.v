/*
Finds the max value in a 2200 point window (number of points in a 1126 Hz pulse at 2.5MHz), using a 16x boxfilter.
Returns half of this value (within the range [200, 15000]) as a trigger threshold.
*/

module set_threshold (
    input [15:0] signal,  // 16-bit input signal
    input clk,    
	 output [15:0] threshold
);

    reg [15:0] avg;     // running 16 point average
	 reg [15:0] max;
	 
    reg [15:0] signal_1, signal_2, signal_3, signal_4;
	 reg [15:0] signal_5, signal_6, signal_7, signal_8;
	 reg [15:0] signal_9, signal_10, signal_11, signal_12;
	 reg [15:0] signal_13, signal_14, signal_15, signal_16;
	 
	 reg [19:0] avg_20; // to hold accumualated sum
	 
	 reg [11:0] count;
	 reg [15:0] max_tmp;

	 assign threshold = (max < 400)? 200 : (max > 30000 )? 15000: max >> 1; 
	 
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
		signal_9 <= signal_8;
		signal_10 <= signal_9;
		signal_11 <= signal_10;
		signal_12 <= signal_11;
		signal_13 <= signal_12;
		signal_14 <= signal_13;
		signal_15 <= signal_14;
		signal_16 <= signal_15;
		
		avg_20 <= (signal_1 + signal_2 + signal_3 + signal_4 + signal_5 + signal_6 + signal_7 + signal_8 + signal_9 + signal_10 + signal_11 + signal_12 + signal_13 + signal_14 + signal_15 + signal_16) >> 4;// 16x avg
		avg <= avg_20[15:0];
		
		if(count == 2200) begin
			count <= 0;
			max_tmp <= 0;
			max <= max_tmp;
		end
		else begin
			count <= count + 1;
			if(avg > max_tmp) begin
				max_tmp <= avg;
			end
		end
     
    end

endmodule
