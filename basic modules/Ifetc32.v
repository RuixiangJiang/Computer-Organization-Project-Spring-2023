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
    output reg [31:0] link_addr // (pc + 4) to Decoder which is used by Jal instruction
);
    reg[31:0] PC, nextPC;
    assign branch_base_addr = PC + 4;

    prgrom instmem(
        .clka(clock), // input wire clka
        .addra(PC[15:2]), // input wire [13:0] addra
        .douta(Instruction) // output wire [31:0] douta
    );

    always @(*) begin
        // beq, bne
        if ((Branch && Zero) || (nBranch && ~Zero)) nextPC = Addr_result;
        // Jr
        else if (Jr) nextPC = Read_data_1;
        // other
        else nextPC = PC + 4;
    end

    always @(negedge clock) begin
        if (reset) PC <= 0;
        else begin
            if (Jmp || Jal) PC <= {PC[31:28], Instruction[25:0], 2'b00};
            else PC <= nextPC;
        end
    end

    always @(posedge Jmp, posedge Jal) begin
        if (Jmp || Jal) link_addr <= (PC + 4);
    end

endmodule