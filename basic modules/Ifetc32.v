`timescale 1ns / 1ps
module Ifetc32(
    output[31:0] Instruction, // the instruction fetched from this module to Decoder and Controller
    output[31:0] branch_base_addr, // (pc + 4) to ALU which is used by Branch type instruction
    input[31:0] Addr_result, // the calculated address from ALU
    input[31:0] Read_data_1, // the address of instruction used by Jr instruction
    input Branch, // current instruction is beq
    input nBranch, // current instruction is bnq
    input Jmp, // current instruction is jump
    input Jal, // current instruction is Jal
    input Jr, // current instruction is Jr
    input Zero, // if the ALUresult is Zero
    input clock,
    input reset,
    output reg [31:0] link_addr, // (pc + 4) to Decoder which is used by Jal instruction
    output reg [31:0] PC,
    input[13:0] rom_adr_i, 
    input upg_rst_i, 
    input upg_clk_i, 
    input upg_wen_i, 
    input[13:0] upg_adr_i, 
    input[31:0] upg_dat_i, 
    input upg_done_i
);
    reg[31:0] nextPC;
    assign branch_base_addr = PC + 4;

    // prgrom instmem(
    //     .clka(clock), // input wire clka
    //     .addra(PC[15:2]), // input wire [13:0] addra
    //     .douta(Instruction) // output wire [31:0] douta
    // );

    always @(*) begin
        // beq, bne
        if ((Branch==1'b1 && Zero==1'b1) || (nBranch==1'b1 && Zero==1'b0)) nextPC = Addr_result;
        // Jr
        else if (Jr==1'b1) nextPC = Read_data_1;
        // other
        else nextPC = PC + 4;
    end

    always @(negedge clock or posedge reset) begin
        if (reset) PC <= 0;
        else begin
            if (Jmp==1'b1 || Jal==1'b1) begin
                link_addr <= nextPC;
                PC <= {PC[31:28], Instruction[25:0], 2'b00}; // jump to the address in instruction[25:0]
            end
            else PC <= nextPC;
        end
    end

    wire no_Uart_mode = upg_rst_i | (~upg_rst_i & upg_done_i); // judge whether uart mode
    
    prgrom instmem(
        .clka(no_Uart_mode? clock: upg_clk_i),
        .wea(no_Uart_mode? 1'b0: upg_wen_i),
        .addra(no_Uart_mode? rom_adr_i: upg_adr_i),
        .dina(no_Uart_mode? 32'h00000000: upg_dat_i),
        .douta(Instruction) 
    ); // program memory

endmodule