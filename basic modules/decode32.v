`timescale 1ns / 1ps

module decode32(read_data_1, read_data_2, Instruction, mem_data, ALU_result, Jal,
    RegWrite, MemtoReg, RegDst, Sign_extend, clock, reset, opcplus4, hi, lo);

    input clock, reset;
    input [31:0] Instruction;
    input [31:0] mem_data;
    input [31:0] ALU_result;
    input [31:0] hi_from_ALU;
    input [31:0] lo_from_ALU;
    input RegWrite, MemtoReg, Jal, RegDst;
    input [31:0] opcplus4;

    output [31:0] read_data_1;
    output [31:0] read_data_2;
    output [31:0] Sign_extend;

    reg[31:0] registers[0:31];

    wire R_format = (Instruction[31:26] == 6'b0) ? 1 : 0;
    wire J_format = (Instruction[5:0] == 6'b000010 || Instruction[5:0] == 6'b000011) ? 1 : 0;
    wire I_format = (!R_format && !J_format) ? 1 : 0;

    reg[31:0] lo;
    reg[31:0] hi;
    wire hi_lo_calculate = Instruction[31:26] == 6'b000000 &&
        (Instruction[5:0] == 6'b011000 ||
         Instruction[5:0] == 6'b011001 ||
         Instruction[5:0] == 6'b011010 ||
         Instruction[5:0] == 6'b011011);
    wire mflo = (Instruction[31:26] == 6'b000000 && Instruction[5:0] == 6'b010010)? 1'b1: 1'b0;
    wire mfhi = (Instruction[31:26] == 6'b000000 && Instruction[5:0] == 6'b010000)? 1'b1: 1'b0;

    wire[4:0] rs = Instruction[25:21];
    wire[4:0] rt = Instruction[20:16];
    wire[4:0] rd = Instruction[15:11];
    wire[4:0] writeReg = (Jal)? 5'b11111 : (RegDst)? rd : rt;

    // wire is_addi = (Instruction[31:26] == 6'b001000) ? 1 : 0;
    wire is_addiu = (Instruction[31:26] == 6'b001001) ? 1 : 0;
    wire is_sltiu = (Instruction[31:26] == 6'b001011) ? 1 : 0;
    wire is_andi = (Instruction[31:26] == 6'b001100) ? 1 : 0;
    wire is_ori = (Instruction[31:26] == 6'b001101) ? 1 : 0;
    wire is_xori = (Instruction[31:26] == 6'b001110) ? 1 : 0;

    integer i;
    always @(posedge clock) begin
        if (reset) begin
            for (i = 0;i < 32;i = i + 1) registers[i] <= 32'b0;
            hi <= 32'b0;
            lo <= 32'b0;
        end
        else begin
            if (RegWrite && writeReg) begin
                if (Jal) begin
                    registers[writeReg] <= opcplus4;
                end
                else if (MemtoReg) begin
                    registers[writeReg] <= mem_data;
                end
                else begin
                    registers[writeReg] <= ALU_result;
                end
            end
            if (hi_lo_calculate) begin
                hi <= hi_from_ALU;
                lo <= lo_from_ALU;
            end
            if (mfhi && rd) registers[rd] <= hi;
            if (mflo && rd) registers[rd] <= lo;
        end
    end

    assign read_data_1 = registers[rs];
    assign read_data_2 = registers[rt];
    assign Sign_extend = (is_addiu || is_sltiu || is_andi || is_ori || is_xori) ? {16'b0, Instruction[15:0]} : {{16{Instruction[15]}}, Instruction[15:0]};
endmodule