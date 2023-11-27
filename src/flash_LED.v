//////////////////////////////////////////////////////////////////////////////////
module pulse_1Hz(
    input clk,  //50 MHz clock
	 output reg pulse_1Hz
	 );
	 
parameter  CLK_PERIOD = 20; // ns, with 50 MHz clock
parameter  HALF_PERIOD = 0.5; // seconds
parameter  HALF_MAX = (1000000000*FLASH_PERIOD)/CLK_PERIOD; 
parameter  MAX = 2*HALF_MAX; 

reg [27: 0] counter;

always @(posedge clk)
begin
	if (counter > MAX) begin counter <= 0; pulse_1Hz <= 0; end
	else if ( counter < HALF_MAX) begin counter <= counter + 1; pulse_1Hz <= 1; end
	     else begin counter <= counter + 1; pulse_1Hz <= 0; end
end
    
endmodule