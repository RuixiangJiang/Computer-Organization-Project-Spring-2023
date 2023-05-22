`timescale 1ns / 1ps

module Switch(
    input switclk, // clock of switch
    input switrst, // reset of switch
    input switcs, // switch chip-select from memorio
    input[1:0] switchaddr,
    input switread, // read-signal
    output reg[7:0] switch_wdata, // 16 bit data write to CPU
    input[15:0] switch_rdata, // 16 bit data read from ego1
    input check_button
);
    always @ (negedge switclk or posedge switrst) begin
        if(switrst) switch_wdata <= 0;
		else if (switcs && switread) begin
            if(switchaddr == 2'b00)
                switch_wdata <=switch_rdata[7:0];
            else if(switchaddr == 2'b10)
                switch_wdata <= switch_rdata[15:8];
            else if(switchaddr == 2'b11)
                switch_wdata <= {7'b0,check_button};
            else
            switch_wdata <= switch_rdata;
		end
        else switch_wdata <= switch_wdata;
    end

endmodule