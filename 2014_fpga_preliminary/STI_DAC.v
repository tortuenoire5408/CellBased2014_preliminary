module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       oem_finish, oem_dataout, oem_addr,
	       odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end;
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output		so_data, so_valid;

output  oem_finish, odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr;
output [4:0] oem_addr;
output [7:0] oem_dataout;
//==============================================================================
wire		so_data, so_valid;
//==============================================================================

STI u1(.clk(clk) ,.reset(reset), .load(load), .pi_data(pi_data), .pi_length(pi_length),
	      .pi_fill(pi_fill), .pi_msb(pi_msb), .pi_low(pi_low), .pi_end(pi_end),
	      .so_data(so_data), .so_valid(so_valid));

DAC u2(.clk(clk) ,.reset(reset), .so_data(so_data), .so_valid(so_valid),
	      .oem_finish(oem_finish), .oem_addr(oem_addr), .oem_dataout(oem_dataout),
	      .odd1_wr(odd1_wr), .odd2_wr(odd2_wr), .odd3_wr(odd3_wr), .odd4_wr(odd4_wr),
	      .even1_wr(even1_wr), .even2_wr(even2_wr), .even3_wr(even3_wr), .even4_wr(even4_wr));

//==============================================================================
endmodule
