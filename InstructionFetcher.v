`timescale 1ns / 1ps
module InstructionFetcher(
    output[31:0] Instruction, // the instruction fetched from this module to Decoder and Controller
    output[31:0] addressBranchBase, // (pc + 4) to ALU which is used by branch type instruction
    output[31:0] addressLink, // (pc + 4) to Decoder which is used by jal instruction

    // From CPU Top
    input clk,
    input rst,

    // From ALU
    input addressALUResult, // the calculated address from ALU
    input Zero, // if the ALUresult is zero

    // From Decoder
    input[31:0] ReadData1, // the address of instruction used by jr instruction

    // From Controller
    input Branch, // current instruction is beq
    input nBranch, // current instruction is bnq
    input Jmp, // current instruction is jump
    input Jal, // current instruction is jal
    input Jr // current instruction is jr
)
    reg[31:0] PC, nextPC;
    reg[31:0] jalPC;
    assign addressBranchBase = PC + 4;
    assign addressLink = jalPC;
    
    always @(*) begin
        // beq, bne
        if ((Branch == 1 && Zero == 1) || (nBranch == 1 && Zero == 0)) nextPC = addressALUResult;
        // jr
        else if (Jr == 1) nextPC = ReadData1;
        // other
        else nextPC = PC + 4;
    end

    always @(clk) begin
        if (rst == 1) PC <= 32'h00000000;
        else begin
            if (Jal == 1) jalPC = PC + 4;
            if (Jmp == 1 || Jal == 1) PC <= {PC[31:28], Instruction[25:0], 2'b00};
            else PC <= nextPC;
        end
    end

endmodule