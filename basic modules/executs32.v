`timescale 1ns / 1ps
module executs32(
    input[31:0] Read_data_1,
    input[31:0] Read_data_2,
    input[31:0] Sign_extend, // instruction[15:0] AFTER sign-extension
    input[5:0] Function_opcode, // instruction[5:0]
    input[5:0] Exe_opcode, // instruction[31:26]
    input[1:0] ALUOp, // ALUOp = {if R-type, if branch}
    input[4:0] Shamt, // instruction[10:6]
    input Sftmd, // Sftmd = if it is a shift instruction
    input ALUSrc, // ALUSrc = if 2nd operand is an immediate
    input I_format, // I_format = if it is an I-Type instruction except beq, bne, lw, sw
    input Jr, // Jr = if it is an Jr instruction
    output Zero, // if the ALU_Result is zero
    output reg[31:0] regALU_Result, // the ALU calculation result
    output[31:0] Addr_Result, // the calculated instruction address
    input[31:0] PC_plus_4 // program counter AFTER adding 4
);
    wire[31:0] Ainput, Binput; // two operands for calculation
    wire[5:0] execode; // to solve ALUcontrol
    wire[2:0] ALUcontrol; // the control signals which affact operation in ALU directely
    wire[2:0] sftm; // identify the types of shift instruction, equals to Exe_opcode[2:0]
    reg[31:0] shiftResult; // the result of shift operation
    reg[31:0] arithmeticResult; // the result of arithmetic or logic calculation
    // reg[31:0] regALU_Result; // reg of the ALU calculation result

    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];

    // assign ALU_Result = regALU_Result;
    assign Addr_Result = (Sign_extend << 2) + PC_plus_4;

    assign execode = (I_format == 0) ? Function_opcode : {3'b000, Exe_opcode[2:0]};
    assign ALUcontrol[0] = (execode[0] | execode[3]) & ALUOp[1];
    assign ALUcontrol[1] = (!execode[2]) | (!ALUOp[1]);
    assign ALUcontrol[2] = (execode[1] & ALUOp[1]) | ALUOp[0];

    always @(*) begin
        case (ALUcontrol)
            3'b000: arithmeticResult = Ainput & Binput; // and, andi
            3'b001: arithmeticResult = Ainput | Binput; // or, ori
            3'b010: arithmeticResult = $signed(Ainput) + $signed(Binput); // add, addi
            3'b011: arithmeticResult = Ainput + Binput; // addu, addiu
            3'b100: arithmeticResult = Ainput ^ Binput; // xor
            3'b101: arithmeticResult = ~(Ainput | Binput); // nor
            3'b110: arithmeticResult = $signed(Ainput) - $signed(Binput); // sub, subi, beq, bne
            3'b111: arithmeticResult = Ainput - Binput; // subu
            default: arithmeticResult = 32'h00000000;
        endcase
    end

    assign sftm = Function_opcode[2:0];
    always @(*) begin
        if (Sftmd) case (sftm[2:0])
            3'b000: shiftResult = Binput << Shamt; // sll
            3'b010: shiftResult = Binput >> Shamt; // srl
            3'b100: shiftResult = Binput << Ainput; // sllv
            3'b110: shiftResult = Binput >> Ainput; // srlv
            3'b011: shiftResult = $signed(Binput) >>> Shamt; // sra
            3'b111: shiftResult = $signed(Binput) >>> Ainput; // srav
            default: shiftResult = Binput;
        endcase
        else shiftResult = Binput;
    end

    always @(*) begin
        // slt, slti, sltu, sltiu
        if (((ALUcontrol == 3'b111 && execode[3] == 1)) || (I_format == 1 && ALUcontrol[2:1] == 2'b11)) 
            regALU_Result = ($signed(Ainput) < $signed(Binput));
        // lui
        else if (ALUcontrol == 3'b101 && I_format == 1) regALU_Result[31:0] = {Binput[15:0], 16'b0};
        // shift
        else if (Sftmd == 1) regALU_Result = shiftResult;
        //other types of operation in ALU
        else regALU_Result = arithmeticResult[31:0];
    end
    assign Zero = (arithmeticResult == 32'h00000000) ? 1'b1 : 1'b0;

endmodule