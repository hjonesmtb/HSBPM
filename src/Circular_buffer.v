`timescale 1ns / 1ps
//based on x4_Channel_buffer of E_linac_FC_V2 project
//Oct.20,2020
//Feb.21,2023: change buffer width to 64 bit.
// changed to 1024 depth.
//March 24,2023: added clken signal to allow different data rate

//////////////////////////////////////////////////////////////////////////////////
module Circular_Buffer(
 input [FULL_WIDTH-1:0] DIN,
 input RST,
 input TRIG,
 input clk, //50 ns clock
 input clken, //clk enable
 input RD,
 output reg EVENT_RDY,
 output [FULL_WIDTH-1:0] DOUT
    );
	 
parameter FILL_TIME = 1024; //2 ms dead time 
parameter BUFFER_ADDR_BITS = 10; //1024 words ram
parameter TAIL_LEN = 900; // keep 900 samples  after trigger
parameter EVENT_LEN = 1024; // total length = ram depth, for 2 us ADC, this is 2 ms.
 
reg WR/*synthesis keep*/;
wire gate/*synthesis keep*/;
assign gate = WR? clken : 1'b1;

reg [BUFFER_ADDR_BITS-1:0] sp_adr;  
wire [BUFFER_ADDR_BITS-1:0] addr = sp_adr;

//this ram is actually 1024 deep now, Feb.28,2021, SL
ram4096 buffer(
	.address(addr),
	.clock(clk),
	.clken(gate),
	.data(DIN),
	.wren(WR),
	.q(DOUT));

parameter  state_init = 3'b000; //loading 100 leading length
parameter  state_read = 3'b001; //writing in and reading out garbage
parameter  state_load = 3'b010; //storing event
parameter  state_wait = 3'b011; //reading event
parameter  state_fill = 3'b100;

reg [2:0] state/*synthesis keep*/;
reg [15:0] cnt/*synthesis keep*/;


always @ (posedge clk ) 
begin
	if (RST) 
	begin
		state <= state_init;
		WR <= 1;
		EVENT_RDY <= 0;
		cnt <= 0;
		sp_adr <= 0;
	end
	
	else 
	begin
		case (state)
		state_init:		
		if (clken)
			begin  
		      WR <= 1; 
				sp_adr <= sp_adr + 1;
				cnt <= 0;
				if(TRIG)	state <= state_load;				
			end
		state_load:
		if (clken)
			begin 
				cnt <= cnt +1;
				sp_adr <= sp_adr + 1;
				if(cnt > TAIL_LEN )
					begin
						WR <= 0;
						EVENT_RDY <= 1;
						cnt <= 0;
						state <= state_read;
					end		
			end
		state_read:			
		if(( RD == 1) && ( cnt < EVENT_LEN-1))
		  begin
			sp_adr <= sp_adr + 1;
			cnt <= cnt +1;
		  end 
      else if (cnt >= EVENT_LEN-1) begin EVENT_RDY <= 0; state <= state_wait; end
		
		state_wait: 
		if (RD == 0) begin cnt <= 0; state <= state_fill; end
		
		state_fill:
		if (clken)
			begin 
				WR <= 1; 
				sp_adr <= sp_adr + 1;
				cnt <= cnt + 1;
				if(cnt > FILL_TIME ) state <= state_init;
			end
		
		default:
		state <= state_init;
		
	 endcase
	end
end

endmodule
