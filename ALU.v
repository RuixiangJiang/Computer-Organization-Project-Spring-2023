`timescale 1ns / 1ps
module ALU(
    //From Decoder
    input[31:0] ReadData1,
    input[31:0] ReadData2,
    input[31:0] SignExtend, // instruction[15:0] AFTER sign-extension

    //From IFetch
    input[5:0] opcode, // instruction[31:26]
    input[4:0] shamt, // instruction[10:6]
    input[5:0] funct, // instruction[5:0]
    input[31:0] pc // program counter AFTER adding 4

    //From Controller
    input[1:0] ALUop, // ALUop = {if R-type, if branch}
    input ALUsrc, // ALUsrc = if 2nd operand is an immediate
    input I_format, // I_format = if it is an I-Type instruction except beq, bne, lw, sw
    input sftmd, // sftmd = if it is a shift instruction

    output[31:0] ALUResult, // the ALU calculation result
    output Zero, // if the ALUResult is zero
    output[31:0] AddrResult // the calculated instruction address
)
    wire[31:0] Ainput, Binput; // two operands for calculation
    wire[5:0] execode; // to solve ALUcontrol
    wire[2:0] ALUcontrol; // the control signals which affact operation in ALU directely
    wire[2:0] sftm; // identify the types of shift instruction, equals to funct[2:0]
    reg[31:0] shiftResult; // the result of shift operation
    reg[31:0] arithmeticResult; // the result of arithmetic or logic calculation
    reg[31:0] regALUResult; // reg of the ALU calculation result
    wire[32:0] AddrBranch; // the calculated address of the instruction, AddrResult is AddrBranch[31:0]

    assign Ainput = ReadData1;
    assign Binput = (ALUsrc == 0) ? ReadData2 : SignExtend[31:0];

    assign execode = (I_format == 0) ? funct : {3'b000, opcode[2:0]};
    assign ALUcontrol[0] = (execode[0] | execode[3]) & ALUop[1];
    assign ALUcontrol[1] = (!execode[2]) | (!ALUop[1]);
    assign ALUcontrol[2] = (execode[1] & ALUop[1]) | ALUop[0];

    always @(ALUcontrol or Ainput or Binput) begin
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

    assign sftm = funct[2:0];
    always @(*) begin
        if (sftmd) case (sftm[2:0])
            3'b000: shiftResult = Binput << shamt; // sll
            3'b010: shiftResult = Binput >> shamt; // srl
            3'b100: shiftResult = Binput << Ainput; // sllv
            3'b110: shiftResult = Binput >> Ainput; // srlv
            3'b011: shiftResult = $signed(Binput) >> shamt; // sra
            3'b111: shiftResult = $signed(Binput) >> Ainput; // srav
        endcase
        else shiftResult = Binput;
    end

    always @(*) begin
        // slt, slti, sltu, sltiu
        if (((ALUcontrol == 3'b111 && execode[3] == 1)) || (I_format == 1 && ALUcontrol[2:1] == 2'b11)) begin
            if (execode[2:0] == 3'b011) regALUResult = (Ainput - Binput < 0) ? 1 : 0;
            else regALUResult = ($signed(Ainput) - $signed(Binput) < 0) ? 1 : 0;
        end
        // lui
        else if (ALUcontrol == 3'b101 && I_format == 1) regALUResult[31:0] = {Binput[15:0], 16'b0};
        // shift
        else if (sftmd == 1) regALUResult = shiftResult;
        //other types of operation in ALU
        else regALUResult = arithmeticResult[31:0];
    end
    assign Zero = (arithmeticResult == 32'h00000000) ? 1'b1 : 1'b0;

endmodule