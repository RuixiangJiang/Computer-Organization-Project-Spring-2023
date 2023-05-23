`timescale 1ns / 1ps

module ledDriver(
    input ledclk,
    input ledrst,
    input ledwrite,
    input ledcs, // led chip-select
    input[1:0] ledaddr,
    input[7:0] ledinputdata,
    output reg[15:0] ledout
);
// driver of the led
    always @(posedge ledclk or posedge ledrst) begin
        if (ledrst) ledout <= 16'h0;
        else if (ledcs && ledwrite) begin
            if(ledaddr == 2'b00) // 0xFFFFFC60
                ledout[7:0] <= ledinputdata;
            else if(ledaddr === 2'b10) // 0xFFFFC62
                ledout[15:8] <= ledinputdata;
            else
                ledout <= ledinputdata;
        end
        else ledout <= ledout;
    end

endmodule