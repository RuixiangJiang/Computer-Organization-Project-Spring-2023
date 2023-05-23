`timescale 1ns / 1ps
`include "header.vh"

module decode32(read_data_1, read_data_2, Instruction, mem_data, ALU_result, Jal,
    RegWrite, MemtoReg, RegDst, Sign_extend, clock, reset, opcplus4, 
    hi_from_ALU, lo_from_ALU);

    input clock, reset; // clock and reset
    input [31:0] Instruction; // instruction from ifetch module
    input [31:0] mem_data;
    input [31:0] ALU_result; // the result from ALU
    input [31:0] hi_from_ALU; // the hi register result from ALU
    input [31:0] lo_from_ALU; // the lo register result from ALU
    input RegWrite, MemtoReg, Jal, RegDst;
    input [31:0] opcplus4;

    output [31:0] read_data_1; // the data read from register file
    output [31:0] read_data_2; // the data read from register file
    output [31:0] Sign_extend; // the sign-extended immediate value

    reg[31:0] registers[0:31]; // 32 registers

    wire R_format = (Instruction[31:26] == 6'b0) ? 1 : 0; // judge whether the instruction is R-type
    wire J_format = (Instruction[5:0] == 6'b000010 || Instruction[5:0] == 6'b000011) ? 1 : 0; // judge whether the instruction is J-type
    wire I_format = (!R_format && !J_format) ? 1 : 0; // judge whether the instruction is I-type

    reg[31:0] lo;
    reg[31:0] hi;
    wire hi_lo_calculate = Instruction[31:26] == 6'b000000 &&
        (Instruction[5:0] == 6'b011000 ||
         Instruction[5:0] == 6'b011001 ||
         Instruction[5:0] == 6'b011010 ||
         Instruction[5:0] == 6'b011011); // judge whether the instruction needs hi/lo
    wire mflo = (Instruction[31:26] == 6'b000000 && Instruction[5:0] == 6'b010010)? 1'b1: 1'b0; // judge whether the instruction is mflo
    wire mfhi = (Instruction[31:26] == 6'b000000 && Instruction[5:0] == 6'b010000)? 1'b1: 1'b0; // judge whether the instruction is mfhi

    wire[4:0] rs = Instruction[25:21]; // the index of the rs register
    wire[4:0] rt = Instruction[20:16]; // the index of the rt register
    wire[4:0] rd = Instruction[15:11]; // the index of the rd register
    wire[4:0] writeReg = (Jal)? 5'b11111 : (RegDst)? rd : rt; // the index of the register to be written

    // wire is_addi = (Instruction[31:26] == 6'b001000) ? 1 : 0;
    wire is_addiu = (Instruction[31:26] == `addiu_code) ? 1 : 0; // judge whether the instruction is addiu
    wire is_sltiu = (Instruction[31:26] == `sltiu_code) ? 1 : 0; // judge whether the instruction is sltiu
    wire is_andi = (Instruction[31:26] == `andi_code) ? 1 : 0; // judge whether the instruction is andi
    wire is_ori = (Instruction[31:26] == `ori_code) ? 1 : 0; // judge whether the instruction is ori
    wire is_xori = (Instruction[31:26] == `xori_code) ? 1 : 0; // judge whether the instruction is xori

    integer i;
    always @(posedge clock) begin
        if (reset) begin
            for (i = 0;i < 32;i = i + 1) registers[i] <= 32'b0; // initialize registers
            hi <= 32'b0; // initialize hi
            lo <= 32'b0; // initialize lo
        end
        else begin
            if (RegWrite && writeReg) begin
                if (Jal) begin
                    registers[writeReg] <= opcplus4; // write the address of the next instruction to the register
                end
                else if (MemtoReg) begin
                    registers[writeReg] <= mem_data; // write the data read from memory to the register
                end
                else begin
                    registers[writeReg] <= ALU_result; // write the result from ALU to the register
                end
            end
            if (hi_lo_calculate) begin // calculate hi and lo
                hi <= hi_from_ALU;
                lo <= lo_from_ALU;
            end
            if (mfhi && rd) registers[rd] <= hi; // write hi to the register
            if (mflo && rd) registers[rd] <= lo; // write lo to the register
        end
    end
    assign read_data_1 = registers[rs]; // read data from register file
    assign read_data_2 = registers[rt]; // read data from register file
    assign Sign_extend = (is_addiu || is_sltiu || is_andi || is_ori || is_xori) ? {16'b0, Instruction[15:0]} : {{16{Instruction[15]}}, Instruction[15:0]};
    // sign-extend the immediate value
endmodule