`timescale 1ns / 1ps

module Decoder(
    clk, rst, instruction, 
    memData, aluResult, regWrite, 
    memWrite, jal, regDst, addressLink,
    readData1, readData2, extendedImm
);

    input clk, rst;
    input [31:0] instruction;
    input [31:0] memData;
    input [31:0] aluResult;
    input regWrite, memWrite, jal, regDst; // regWrite-是否写入reg
    input [31:0] addressLink;//取值单元传给jal指令的地址

    output [31:0] readData1;
    output [31:0] readData2;
    output [31:0] extendedImm;

    reg[31:0] registers[0:31];

    wire R_format = (instruction[31:26] == 6'b0) ? 1 : 0;
    wire J_format = (instruction[5:0] == 6'b000010 || instruction[5:0] == 6'b000011) ? 1 : 0;
    wire I_format = (!R_format && !J_format) ? 1 : 0;

    wire[4:0] rs = instruction[25:21];
    wire[4:0] rt = instruction[20:16];
    wire[4:0] rd = instruction[15:11];
    wire[4:0] writeReg = (jal)? 5'b11111 : (regDst)? rd : rt; // writeReg-要写入的reg

    //判断是否为zero-extension
    wire is_addiu = (instruction[31:26] == 6'b001001) ? 1 : 0;
    wire is_sltiu = (instruction[31:26] == 6'b001011) ? 1 : 0;
    wire is_andi = (instruction[31:26] == 6'b001100) ? 1 : 0;
    wire is_ori = (instruction[31:26] == 6'b001101) ? 1 : 0;
    wire is_xori = (instruction[31:26] == 6'b001110) ? 1 : 0;

    integer i;
    always @(posedge clk) begin
        if (rst) begin
          for (i = 0;i < 32;i = i + 1) begin
            registers[i] <= 32'b0;
          end
        end
        else begin
        end

        if (regWrite && writeReg) begin
            if (jal) begin
                registers[writeReg] = addressLink;
            end
            else if (memWrite) begin
                registers[writeReg] = memData;
            end
            else begin
                registers[writeReg] = aluResult;
            end
        end
    end

    assign readData1 = registers[rs];
    assign readData2 = registers[rt];
    assign extendedImm = (is_addiu || is_sltiu || is_andi || is_ori || is_xori) ? {16'b0, instruction[15:0]} : {{16{instruction[15]}}, instruction[15:0]};

endmodule