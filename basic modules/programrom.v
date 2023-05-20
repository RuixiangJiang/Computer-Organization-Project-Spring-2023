`timescale 1ns / 1ps


module programrom(
    rom_clk_i, rom_adr_i, Instruction_o, upg_rst_i, upg_clk_i, upg_wen_i, upg_adr_i, upg_dat_i, upg_done_i
);
    input rom_clk_i;
    input[13:0] rom_adr_i;
    output[31:0] Instruction_o;
    
    input upg_rst_i;
    input upg_clk_i;
    input upg_wen_i;
    input[13:0] upg_adr_i;
    input[31:0] upg_dat_i;
    input upg_done_i;
    
    wire no_Uart_mode = upg_rst_i | (~upg_rst_i & upg_done_i);
    
    prgrom instmem(
        .clka(no_Uart_mode? rom_clk_i: upg_clk_i),
        .wea(no_Uart_mode? 1'b0: upg_wen_i),
        .addra(no_Uart_mode? rom_adr_i: upg_adr_i),
        .dina(no_Uart_mode? 32'h00000000: upg_dat_i),
        .douta(Instruction_o) 
    );
    
endmodule
