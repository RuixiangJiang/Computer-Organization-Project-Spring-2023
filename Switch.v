`timescale 1ns / 1ps

module Switch(clk, rst,switch_wdata, switch_rdata);
    input clk;			       //  时钟信号
    input rst;			       //  复位信号
    output [15:0] switch_wdata;	     //  传入给memorio的data
    input [15:0] switch_rdata;		    //  从板上读的24位开关数据
    reg [15:0] switch_wdata;
    always@(negedge clk or posedge rst) begin
        if(rst) begin
            switch_wdata <= 0;
        end
		else
            begin
			switch_wdata[15:0] <= { 8'h00, switch_rdata[15:8] }; //data output, upper 8 bits extended with zero
			end
        end
endmodule
