`timescale 1ns / 1ps
module key1000 #
(
parameter CLK_FREQ = 100000000
)
(
input clk_i,
input key_i,
output key_cap
);
//10ms
parameter CNT_1000MS = (CLK_FREQ/10 - 1'b1);
parameter KEY_S0 = 2'd0;
parameter KEY_S1 = 2'd1;
parameter KEY_S2 = 2'd2;
parameter KEY_S3 = 2'd3;
reg [34:0] cnt1000ms = 35'd0;
(*mark_debug = "true"*) reg [1:0] key_s = 2'b0;
(*mark_debug = "true"*) reg [1:0] key_s_r = 2'b0;
(*mark_debug = "true"*) wire en_1000ms ;
assign en_1000ms = (cnt1000ms == CNT_1000MS);
assign key_cap = (key_s==KEY_S2)&&(key_s_r==KEY_S1);
always @(posedge clk_i)
	begin
		if(cnt1000ms < CNT_1000MS)
			cnt1000ms <= cnt1000ms + 1'b1;
		else
			cnt1000ms <= 35'd0;
	end
always @(posedge clk_i)
	begin
		key_s_r <= key_s;
	end
always @(posedge clk_i)
	begin
		if(en_1000ms)
			begin
				case(key_s)
					KEY_S0:
						begin
							if(!key_i)
								key_s <= KEY_S1;
						end
					KEY_S1:
						begin
							if(!key_i)
								key_s <= KEY_S2;
							else
								key_s <= KEY_S0;
						end
					KEY_S2:
						begin
							if(key_i)
								key_s <= KEY_S3;
						end
					KEY_S3:
						begin
							if(key_i)
								key_s <= KEY_S0;
							else
								key_s <= KEY_S2;
						end
				endcase
			end
	end
endmodule
