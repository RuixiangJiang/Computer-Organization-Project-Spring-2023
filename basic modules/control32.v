`timescale 1ns / 1ps

module control32(Opcode, Function_opcode, Jr, RegDST, 
ALUSrc, MemorIOtoReg, RegWrite, MemWrite, MemRead, Branch, nBranch, 
Jmp, Jal, I_format, Sftmd, ALUOp, Alu_resultHigh, IORead, IOWrite);
    input[5:0]   Opcode;            // instruction[31..26] - the high 6 bits of the instruction from the IFetch module
    input[5:0]   Function_opcode;  	// instructions[5..0] - the low 6 bits of the instruction from the IFetch module, used to distinguish instructions in r-type
    output       Jr;         	 // 1 if the current instruction is jr, 0 otherwise
    output       RegDST;          // 1 if the destination register is rd, 0 if the destination register is rt
    output       ALUSrc;          // 1 if the second operand (Binput in ALU) is an immediate value (except for beq, bne), otherwise the second operand comes from the register
    output       MemorIOtoReg;     // 1 if data written to register is read from memory or I/O, 0 if data written to register is the output of ALU module
    output       RegWrite;   	  // 1 if the instruction needs to write to register, 0 otherwise
    output       Branch;        //  1 if the current instruction is beq, 0 otherwise
    output       nBranch;       //  1 if the current instruction is bne, 0 otherwise
    output       Jmp;            //  1 if the current instruction is j, 0 otherwise
    output       Jal;            //  1 if the current instruction is jal, 0 otherwise
    output       I_format;      //  1 if the instruction is I-type except for beq, bne, lw and sw; 0 otherwise
    output       Sftmd;         //  1 if the instruction is a shift instruction, 0 otherwise
    output[1:0]  ALUOp;        // if the instruction is R-type or I_format, ALUOp's higher bit is 1, 0 otherwise; if the instruction is “beq” or “bne“, ALUOp's lower bit is 1, 0 otherwise
    input[21:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output MemRead; // 1 indicates that the instruction needs to read from the memory
    output MemWrite; // 1 indicates that the instruction needs to write to the memory
    output IORead; // 1 indicates I/O read
    output IOWrite; // 1

    wire lw, sw, beq, bne;
    wire R_format;

    assign R_format = (Opcode == 6'b000000) ? 1'b1 : 1'b0; // 6'b000000 is the opcode of R-type instructions
    assign lw = (Opcode == 6'b100011) ? 1'b1 : 1'b0; // 6'b100011 is the opcode of lw
    assign sw = (Opcode == 6'b101011) ? 1'b1 : 1'b0; // 6'b101011 is the opcode of sw
    assign beq = (Opcode == 6'b000100) ? 1'b1 : 1'b0; // 6'b000100 is the opcode of beq
    assign bne = (Opcode == 6'b000101) ? 1'b1 : 1'b0; // 6'b000101 is the opcode of bne
    assign Jmp = (Opcode == 6'b000010) ? 1'b1 : 1'b0; // 6'b000010 is the opcode of j
    assign Jal = (Opcode == 6'b000011) ? 1'b1 : 1'b0; // 6'b000011 is the opcode of jal
    assign Jr = (R_format && (Function_opcode == 6'b001000)) ? 1'b1 : 1'b0; // 6'b001000 is the function opcode of jr

    // judge control signals
    assign Branch = beq;
    assign nBranch = bne;
    assign RegDST = R_format;
    assign MemorIOtoReg = IORead || MemRead;
    assign RegWrite = ((R_format || lw || Jal || I_format) && !(Jr)) ? 1'b1:1'b0;
    assign MemWrite = ((sw==1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1:1'b0;
    assign MemRead = ((lw==1)&&(Alu_resultHigh[21:0]!=22'h3FFFFF))?1'b1:1'b0;
    assign IORead = ((lw==1)&&(Alu_resultHigh[21:0]==22'h3FFFFF))?1'b1:1'b0;
    assign IOWrite = ((sw==1)&&(Alu_resultHigh[21:0]==22'h3FFFFF))?1'b1:1'b0;
    assign ALUSrc = (lw || sw || I_format) ? 1 : 0;
    assign Sftmd = (R_format && ((Function_opcode == 6'b000000) || (Function_opcode == 6'b000010) 
                    || (Function_opcode == 6'b000100) || (Function_opcode == 6'b000110)
                    || (Function_opcode == 6'b000011) || (Function_opcode == 6'b000111))) ? 1 : 0;
    assign I_format = (Opcode[5:3] == 3'b001) ? 1 : 0;
    assign ALUOp = {(R_format || I_format), (beq || bne)};

endmodule