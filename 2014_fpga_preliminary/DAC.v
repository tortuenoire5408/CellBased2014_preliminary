module DAC(clk ,reset, so_data, so_valid, oem_finish, oem_dataout, oem_addr,
	       odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr);

input		clk, reset;
input		so_data, so_valid;

output  oem_finish, odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr;
output [4:0] oem_addr;
output [7:0] oem_dataout;
//==============================================================================
reg  oem_finish, odd1_wr, odd2_wr, odd3_wr, odd4_wr, even1_wr, even2_wr, even3_wr, even4_wr;
reg [4:0] oem_addr;
reg [7:0] oem_dataout, mem;

reg so_sign, done, odd_state, even_state;
reg [1:0] mux;
reg [2:0] x, y, so_valid_clk_count;
reg [4:0] z;
//==============================================================================

always@(posedge clk) begin
    if(reset) begin
        oem_finish = 0;
        x = 0; y =0; z =0; so_sign = 0;
        so_valid_clk_count = 0;
    end else begin
        if(so_valid == 1) begin
            so_sign = 1;
            so_valid_clk_count = 0;
            y = y + 1;
            if(y == 0) begin
                x = x + 1;
                if(x == 0) z = z + 1;
                else z = z;
            end else x = x;
        end else begin
            so_sign = so_sign;
            so_valid_clk_count = so_valid_clk_count + 1;
            if(so_valid_clk_count >= 4) begin
                so_valid_clk_count = 4;
                y = y + 1;
                if(y == 0) begin
                    x = x + 1;
                    if(x == 0) z = z + 1;
                    else z = z;
                end else x = x;
            end
        end
        if(done) begin
            oem_finish = 1;
            x = 0; y =0; z =0; so_sign = 0;
            so_valid_clk_count = 0; mux = 0;
            odd_state = 0; even_state = 0;
            oem_addr = 0; oem_dataout = 0; mem = 0;
        end else oem_finish = 0;
        if(so_sign) begin
            mem = {mem[6:0], so_data};
            if(y == 0 && ((so_valid !== 0) || (so_valid_clk_count >= 4))) begin
                if(y == 0 && so_valid !== 0) oem_dataout = mem;
                else if(so_valid_clk_count >= 4) oem_dataout = 0;
                odd_state = (x[0] && !z[0]) || (z[0] && !x[0] && (x[1] || x[2])) || (!z[0] && !(x[0] || x[1] || x[2]));
                even_state = (x[0] && z[0]) || (!z[0] && !x[0] && (x[1] || x[2])) || (z[0] && !(x[0] || x[1] || x[2]));
                if(x[0] == 1) begin
                    if(oem_addr >= 0) oem_addr = oem_addr + 1;
                    else oem_addr = 0;
                end else begin
                    oem_addr = oem_addr;
                end
                if(oem_addr == 0 && x== 1) begin
                    if(mux >= 0) mux = mux + 1;
                    else mux = 0;
                end
                if(mux == 0) begin
                    odd1_wr = odd_state;
                    even1_wr = even_state;
                    odd2_wr = 0; odd3_wr = 0; odd4_wr = 0;
                    even2_wr = 0; even3_wr = 0; even4_wr = 0;
                end else if(mux == 1) begin
                    odd2_wr = odd_state;
                    even2_wr = even_state;
                    odd1_wr = 0; odd3_wr = 0; odd4_wr = 0;
                    even1_wr = 0; even3_wr = 0; even4_wr = 0;
                end else if(mux == 2) begin
                    odd3_wr = odd_state;
                    even3_wr = even_state;
                    odd1_wr = 0; odd2_wr = 0; odd4_wr = 0;
                    even1_wr = 0; even2_wr = 0; even4_wr = 0;
                end else begin
                    odd4_wr = odd_state;
                    even4_wr = even_state;
                    odd1_wr = 0; odd2_wr = 0; odd3_wr = 0;
                    even1_wr = 0; even2_wr = 0; even3_wr = 0;
                end
            end
            if(y == 7)begin
                odd1_wr = 0; odd2_wr = 0; odd3_wr = 0; odd4_wr = 0;
                even1_wr = 0; even2_wr = 0; even3_wr = 0; even4_wr = 0;
                if(x == 0 && z == 0 && oem_addr && oem_addr !== 0) begin
                    done = 1;
                end else done = 0;
            end
        end
    end
end

//==============================================================================
endmodule
