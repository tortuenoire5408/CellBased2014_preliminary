module STI(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end;
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output		so_data, so_valid;
//==============================================================================
reg		so_data, so_valid;
reg [1:0] state;

reg		pi_msbC, pi_lowC;
reg	[15:0]	pi_dataC;
reg	[1:0]	pi_lengthC;
reg		pi_fillC;

reg [7:0] pi_mem_s;
reg [23:0] pi_mem_l;
reg [31:0] pi_mem_xl;
reg [4:0] pi_count;
reg [5:0] i;

parameter receive = 2'b00, send = 2'b01, done = 2'b11;
parameter s = 2'b00, m = 2'b01, l = 2'b10, xl = 2'b11;
//==============================================================================

always@(posedge clk or posedge reset) begin
	if(reset) begin
		state = receive;
		so_data = 0;
		so_valid = 0;
		pi_count = 0; i = 0;
	end else begin
		case (state)
			receive: begin
				if(load) begin
					pi_msbC = pi_msb; pi_lowC = pi_low;
					pi_dataC = pi_data; pi_lengthC = pi_length;
					pi_fillC = pi_fill;
					if(pi_lengthC == xl) begin
						pi_count = 31;
						if(pi_fillC == 1) begin
							pi_mem_xl = {pi_dataC, 8'b00000000, 8'b00000000};
						end else begin
							pi_mem_xl = {8'b00000000, 8'b00000000, pi_dataC};
						end
					end else if(pi_lengthC == l) begin
						pi_count = 23;
						if(pi_fillC == 1) begin
							pi_mem_l = {pi_dataC, 8'b00000000};
						end else begin
							pi_mem_l = {8'b00000000, pi_dataC};
						end
					end else if(pi_lengthC == s) begin
						pi_count = 7;
						if(pi_lowC == 1) begin
							pi_mem_s = pi_dataC[15:8];
						end else begin
							pi_mem_s = pi_dataC[7:0];
						end
					end else begin
						pi_count = 15;
						pi_dataC = pi_dataC;
					end
					state = send;
				end
			end
			send: begin
				so_valid = 1;
				if(pi_lengthC == xl) begin
					if(pi_msbC == 1) begin
						so_data = pi_mem_xl[pi_count - i];
					end else begin
						so_data = pi_mem_xl[i];
					end
				end else if(pi_lengthC == l) begin
					if(pi_msbC == 1) begin
						so_data = pi_mem_l[pi_count - i];
					end else begin
						so_data = pi_mem_l[i];
					end
				end else if(pi_lengthC == s) begin
					if(pi_msbC == 1) begin
						so_data = pi_mem_s[pi_count - i];
					end else begin
						so_data = pi_mem_s[i];
					end
				end else begin
					if(pi_msbC == 1) begin
						so_data = pi_dataC[pi_count - i];
					end else begin
						so_data = pi_dataC[i];
					end
				end
				if(i == (pi_count + 1)) begin
					state = receive;
					so_valid = 0;
					so_data = 0;
					i = 0;
				end else i = i + 1;
				if (pi_end && i == (pi_count + 1)) begin
					state = done;
				end
			end
			done: begin
				so_data = 0;
				so_valid = 0;
				pi_count = 0; i = 0;
			end
			default: begin end
		endcase
	end
end

//==============================================================================
endmodule
