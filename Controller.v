`timescale 1ns / 1ps

//后面应该要统一调整下变量名
module Controller(opcode, funct, Jr, Jmp, Jal, Branch, nBranch, 
RegDST, MemtoReg, RegWrite, MemWrite, ALUSrc, Sftmd, I_format, ALUOp);
    input[5:0] opcode;
    input[5:0] funct;
    output Jr;
    output Jmp;
    output Jal;
    output Branch;
    output nBranch;
    output RegDST;
    output MemtoReg;
    output RegWrite;
    output MemWrite;
    output ALUSrc;
    output Sftmd;
    output I_format;
    output[1:0] ALUOp; // R_type/I_type-2'b10 beq/bne-2'b01 lw/sw-2'b00

    wire lw, sw, beq, bne;
    wire R_format;

    assign R_format = (opcode == 6'b000000) ? 1 : 0;
    assign lw = (opcode == 6'b100011) ? 1 : 0;
    assign sw = (opcode == 6'b101011) ? 1 : 0;
    assign beq = (opcode == 6'b000100) ? 1 : 0;
    assign bne = (opcode == 6'b000101) ? 1 : 0;
    assign Jmp = (opcode == 6'b000010) ? 1 : 0;
    assign Jal = (opcode == 6'b000011) ? 1 : 0;
    assign Jr = (R_format && (funct == 6'b001000)) ? 1 : 0;

    assign Branch = beq;
    assign nBranch = bne;
    assign RegDST = R_format;
    assign MemtoReg = lw;
    assign RegWrite = ((lw || Jal || R_format || I_format) && !(Jr)) ? 1 : 0;
    assign MemWrite = sw;
    assign ALUSrc = (lw || sw || I_format) ? 1 : 0; //是否是有立即数操作
    assign Sftmd = (R_format && ((funct == 6'b000000) || (funct == 6'b000010) 
                    || (funct == 6'b000100) || (funct == 6'b000110)
                    || (funct == 6'b000011) || (funct == 6'b000111))) ? 1 : 0;
    assign I_format = (opcode[5:3] == 3'b001) ? 1 : 0;
    assign ALUOp = {(R_format || I_format), (beq || bne)};

endmodule