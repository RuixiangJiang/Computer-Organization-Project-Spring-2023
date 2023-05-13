`timescale 1ns / 1ps
module Ifetc32(
    output[31:0] Instruction, // the instruction fetched from this module to Decoder and Controller
    output[31:0] branch_base_addr, // (pc + 4) to ALU which is used by branch type instruction
    output[31:0] link_addr, // (pc + 4) to Decoder which is used by jal instruction
    input[31:0] Addr_result, // the calculated address from ALU
    input[31:0] Read_data_1, // the address of instruction used by jr instruction
    input Branch, // current instruction is beq
    input nBranch, // current instruction is bnq
    input Jmp, // current instruction is jump
    input Jal, // current instruction is jal
    input Jr, // current instruction is jr
    input Zero, // if the ALUresult is zero
    input clock,
    input reset
);
    reg[31:0] PC, nextPC;
    reg[31:0] jalPC;
    assign branch_base_addr = PC + 4;
    assign link_addr = jalPC;
    
    always @(*) begin
        // beq, bne
        if ((Branch == 1 && Zero == 1) || (nBranch == 1 && Zero == 0)) nextPC = Addr_result;
        // jr
        else if (Jr == 1) nextPC = Read_data_1;
        // other
        else nextPC = PC + 4;
    end

    always @(negedge clock) begin
        if (reset == 1) PC <= 32'h00000000;
        else begin
            if (Jal == 1) jalPC = PC + 4;
            if (Jmp == 1 || Jal == 1) PC <= {PC[31:28], Instruction[25:0], 2'b00};
            else PC <= nextPC;
        end
    end

endmodule