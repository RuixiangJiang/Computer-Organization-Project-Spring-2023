`timescale 1ns / 1ps

module Switch(
    input switclk, // clock of switch
    input switrst, // reset of switch
    input switcs, // switch chip-select from memorio
    input switread, // read-signal
    output reg[15:0] switch_wdata, // 16 bit data write to CPU
    input[15:0] switch_rdata, // 16 bit data read from ego1
    input[1:0] switaddr
);
    always @ (negedge switclk or posedge switrst) begin
        if(rst) switch_wdata <= 0;
		else if (switcs && switread) begin
            if (switaddr == 2'b00) switch_wdata[15:0] <= switch_rdata[15:0]; // data output, lower 16 bits non-extended
			else if (switaddr == 2'b10) switch_wdata[15:0] <= {8'h00, switch_rdata[15:8]}; // data output, upper 8 bits extended with zero
            else switch_wdata <= switch_wdata;
		end
        else switch_wdata <= switch_wdata;
    end

endmodule