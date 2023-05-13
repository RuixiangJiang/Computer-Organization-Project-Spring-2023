`timescale 1ns / 1ps
module Ifetc32(
    output[31:0] Instruction, // the instruction fetched from this module to Decoder and Controller
    output[31:0] branch_base_addr, // (pc + 4) to ALU which is used by branch type instruction
    input[31:0] Addr_result, // the calculated address from ALU
    input[31:0] Read_data_1, // the address of instruction used by jr instruction
    input Branch, // current instruction is beq
    input nBranch, // current instruction is bnq
    input Jmp, // current instruction is jump
    input Jal, // current instruction is jal
    input Jr, // current instruction is jr
    input Zero, // if the ALUresult is zero
    input clock,
    input reset,
    output reg [31:0] link_addr // (pc + 4) to Decoder which is used by jal instruction
);
    reg[31:0] PC, nextPC;
    reg[31:0] jalPC;
    assign branch_base_addr = PC + 4;
    
    always @(*) begin
        // beq, bne
        if ((Branch && Zero) || (nBranch && ~Zero)) nextPC = Addr_result << 2;
        // jr
        else if (Jr) nextPC = Read_data_1 << 2;
        // other
        else nextPC = PC + 4;
    end

    always @(negedge clock) begin
        if (reset) PC <= 0;
        else begin
            if (Jmp || Jal) PC <= {4'b0000, Instruction[25:0], 2'b00};
            else PC <= nextPC;
        end
    end

    always @(posedge Jmp, posedge Jal) begin
        if (Jmp || Jal) link_addr <= (PC + 4) >> 2;
    end

endmodule