`timescale 1ns / 1ps

module ledDriver(
    input ledclk,
    input ledrst,
    input ledwrite,
    input ledcs, // led chip-select
    input[1:0] ledaddr,
    input[15:0] ledinputdata,
    output reg[15:0] ledout
);
    always @(posedge ledclk or posedge ledrst) begin
        if (ledrst) ledout <= 16'h0;
        else if (ledcs && ledwrite) begin
            ledout <= ledinputdata;
        end
        else ledout <= ledout;
    end

endmodule