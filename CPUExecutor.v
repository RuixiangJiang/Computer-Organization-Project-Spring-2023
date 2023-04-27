`timescale 1ns / 1ps
module ALU (
    input[31:0] ReadData1,
    input[31:0] ReadData2,
    input[31:0] SignExtend, // instruction[15:0] AFTER sign-extension
    output[31:0] ALUResult,
    output[31:0] AddrResult,
    output Zero,
    input ALUSrc,
    input[5:0] opcode, // instruction[31:26]
    input[4:0] shamt, // instruction[10:6]
    input[5:0] funct, // instruction[5:0]
    input[31:0] pc // program counter AFTER adding 4
);
    wire[31:0] OpeData1, OpeData2;
    reg[31:0] calcALUResult, shiftALUResult;
    reg[31:0] regALUResult, regAddrResult;
    assign ALUResult = regALUResult;
    assign AddrResult = regAddrResult;
    assign OpeData1 = ReadData1;
    assign OpeData2 = (ALUSrc == 0) ? ReadData2 : SignExtend;

    always @(*) begin
        if (opcode == 6'b0) begin // R - Type
            case (funct)
                6'b000000: shiftALUResult = OpeData2 << shamt; // sll
                6'b000010: shiftALUResult = OpeData2 >> shamt; // srl
                6'b000011: shiftALUResult = $signed(OpeData2) >>> shamt; // sra
                6'b000100: shiftALUResult = OpeData2 << OpeData1; // sllv
                6'b000110: shiftALUResult = OpeData2 >> OpeData1; // srlv
                6'b000111: shiftALUResult = $signed(OpeData2) >>> OpeData1; // srav
                6'b100000: calcALUResult = $signed(OpeData1) + $signed(OpeData2); // add
                6'b100001: calcALUResult = OpeData1 + OpeData2; // addu
                6'b100010: calcALUResult = $signed(OpeData1) - $signed(OpeData2); // sub
                6'b100011: calcALUResult = OpeData1 - OpeData2; // subu
                6'b100100: calcALUResult = OpeData1 & OpeData2; // and
                6'b100101: calcALUResult = OpeData1 | OpeData2; // or
                6'b100110: calcALUResult = OpeData1 ^ OpeData2; // xor
                6'b100111: calcALUResult = ~ (OpeData1 | OpeData2); // nor
                6'b101010: calcALUResult = ($signed(OpeData1) < $signed(OpeData2)) ? 32'b1 : 32'b0; // slt
                6'b101011: calcALUResult = (OpeData1 < OpeData2) ? 32'b1 : 32'b0; // sltu
                default: begin
                    calcALUResult = 32'h00000000;
                    shiftALUResult = OpeData2;
                end
            endcase
            if (funct == 6'h08) regAddrResult = OpeData1; // jr
            else regAddrResult = (SignExtend << 2) + pc;
            regALUResult = (funct < 6'b100000) ? shiftALUResult : calcALUResult;
        end
        else begin // I - Type or J - Type
            case (opcode)
                6'h8: calcALUResult = $signed(OpeData1) + $signed(OpeData2); // addi
                6'h9: calcALUResult = OpeData1 + OpeData2; // addiu
                6'hc: calcALUResult = OpeData1 & OpeData2; // andi
                6'h4: calcALUResult = $signed(OpeData1) - $signed(OpeData2); // beq
                6'h5: calcALUResult = $signed(OpeData1) - $signed(OpeData2); // bne
                6'h24: // lbu
                6'h25: // lhu
                6'h30: // ll
                6'hf: // lui
                6'h23: // lw
                6'hd: // ori
                6'ha: // slti
                6'hb: // sltiu
                6'h28: // sb
                6'h38: // sc
                6'h29: // sh
                6'h2b: // sw
                default:
            endcase
            case (opcode)
                6'h2: // j
                6'h3: // jal
                default:
            endcase
        end
    end

    assign Zero = (calcALUResult == 32'h00000000) ? 1'b1 : 1'b0;
endmodule