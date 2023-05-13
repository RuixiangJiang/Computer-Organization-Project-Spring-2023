`timescale 1ns / 1ps

module control32(Opcode, Function_opcode, Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);
    input[5:0]   Opcode;            // instruction[31..26] - the high 6 bits of the instruction from the IFetch module
    input[5:0]   Function_opcode;  	// instructions[5..0] - the low 6 bits of the instruction from the IFetch module, used to distinguish instructions in r-type
    output       Jr;         	 // 1 if the current instruction is jr, 0 otherwise
    output       RegDST;          // 1 if the destination register is rd, 0 if the destination register is rt
    output       ALUSrc;          // 1 if the second operand (Binput in ALU) is an immediate value (except for beq, bne), otherwise the second operand comes from the register
    output       MemtoReg;     // 1 if data written to register is read from memory or I/O, 0 if data written to register is the output of ALU module
    output       RegWrite;   	  // 1 if the instruction needs to write to register, 0 otherwise
    output       MemWrite;       //  1 if the instruction needs to write to memory, 0 otherwise
    output       Branch;        //  1 if the current instruction is beq, 0 otherwise
    output       nBranch;       //  1 if the current instruction is bne, 0 otherwise
    output       Jmp;            //  1 if the current instruction is j, 0 otherwise
    output       Jal;            //  1 if the current instruction is jal, 0 otherwise
    output       I_format;      //  1 if the instruction is I-type except for beq, bne, lw and sw; 0 otherwise
    output       Sftmd;         //  1 if the instruction is a shift instruction, 0 otherwise
    output[1:0]  ALUOp;        // if the instruction is R-type or I_format, ALUOp's higher bit is 1, 0 otherwise; if the instruction is “beq” or “bne“, ALUOp's lower bit is 1, 0 otherwise

    wire lw, sw, beq, bne;
    wire R_format;

    assign R_format = (Opcode == 6'b000000) ? 1 : 0;
    assign lw = (Opcode == 6'b100011) ? 1 : 0;
    assign sw = (Opcode == 6'b101011) ? 1 : 0;
    assign beq = (Opcode == 6'b000100) ? 1 : 0;
    assign bne = (Opcode == 6'b000101) ? 1 : 0;
    assign Jmp = (Opcode == 6'b000010) ? 1 : 0;
    assign Jal = (Opcode == 6'b000011) ? 1 : 0;
    assign Jr = (R_format && (Function_opcode == 6'b001000)) ? 1 : 0;

    assign Branch = beq;
    assign nBranch = bne;
    assign RegDST = R_format;
    assign MemtoReg = lw;
    assign RegWrite = ((lw || Jal || R_format || I_format) && !(Jr)) ? 1 : 0;
    assign MemWrite = sw;
    assign ALUSrc = (lw || sw || I_format) ? 1 : 0;
    assign Sftmd = (R_format && ((Function_opcode == 6'b000000) || (Function_opcode == 6'b000010) 
                    || (Function_opcode == 6'b000100) || (Function_opcode == 6'b000110)
                    || (Function_opcode == 6'b000011) || (Function_opcode == 6'b000111))) ? 1 : 0;
    assign I_format = (Opcode[5:3] == 3'b001) ? 1 : 0;
    assign ALUOp = {(R_format || I_format), (beq || bne)};

endmodule