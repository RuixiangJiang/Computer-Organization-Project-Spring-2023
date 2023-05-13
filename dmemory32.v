`timescale 1ns / 1ps

module dmemory32(clock,memWrite, address, writeData, readData);
input wire clock;
input wire memWrite;
input wire [31:0] address;
input wire [31:0] writeData;
output wire [31:0] readData;

wire clk = !clock;

RAM ram(
    .clka(clk),
    .wea(memWrite),
    .addra(address[15:2]),
    .dina(writeData),
    .douta(readData)
    );

endmodule
