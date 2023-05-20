`timescale 1ns / 1ps

module CPU_TOP(
    input clock,
    input rst,
    input[15:0] Switches,
    output[15:0] Lights,
    // Uart
    input iStartRecvCoe,
    input iFpgaUartFromPC,
    output oFpgaUartToPC
);

    //clk
    wire cpu_clk;
    
    wire[31:0] instruction;

    wire[31:0] branch_base_addr;
    wire[31:0] addr_result;
    wire[31:0] addr_out;  
    wire[31:0] link_addr; 
    
    wire[31:0] read_data_1;
    wire[31:0] read_data_2;
    
    wire Branch,nBranch,Jmp,Jal,Jr,Zero;

    
    wire[15:0] io_rdata;
    wire[15:0] io_wdata;

    wire[31:0] mem_data;
    wire[31:0] alu_result;
    wire RegWrite,MemtoReg,RegDst;
    wire[31:0] sign_extend;

    wire[5:0] opcode;
    assign opcode = instruction[31:26];
    wire[5:0] function_opcode;
    assign function_opcode = instruction[5:0];

    wire ALUSrc,Sftmd;
    wire I_format;
    wire[1:0] ALUop;
    wire[21:0] alu_resultHigh;
    assign alu_resultHigh = alu_result[31:10];
    wire MemorIOtoReg;
    wire memRead,memWrite,ioRead,ioWrite;


    wire[5:0] shamt;
    assign shamt = instruction[10:6];
    
    wire[31:0] PC_plus_4;

    wire[31:0] writeData;
    wire[31:0] readData;

    wire SwitchCtrl;
    wire LEDCtrl;
    wire UartCtrl;


    // Uart
    wire[15:0] uartData;
    wire upgclk;
    wire upgclk_o;
    wire upgWriteOutEnable;
    wire upgInputDataFinish; // iFpgaUartFromPC finish
    wire[14:0] upgAddrMemUnit; // data to which memory unit of rom/dmemory
    wire[31:0] upgDataTo; // data to rom or Dmemory
    wire spg_bufg;
    BUFG U1(.I(iStartRecvCoe), .O(spg_bufg)); // de-twitter
    reg upg_rst; // generate uart rst signal
    always @(posedge clock) begin
        if (spg_bufg) upg_rst = 0;
        if (rst) upg_rst = 1;
    end
    wire not_uart_rst = rst | !upg_rst;
    wire kickOff = upg_rst | (~upg_rst & upgInputDataFinish);
    // CPU works on normal/uart mode when kickOff = 1/0
    uart_bmpg_0 uartinst(
        .upg_clk_i(upgclk),
        .upg_rst_i(upg_rst),
        .upg_rx_i(iFpgaUartFromPC),
        .upg_clk_o(upgclk_o),
        .upg_wen_o(upgWriteOutEnable),
        .upg_adr_o(upgInputDataFinish),
        .upg_dat_o(upgDataTo),
        .upg_done_o(upgInputDataFinish)
    );
    uartDriver uartdriverins(
        .iFpgaClock(clock),
        .iCpuClock(cpu_clk),
        .iCpuReset(not_uart_rst),
        .iUartCtrl(UartCtrl),
        .iIoRead(IORead),
        .iUartFromPc(iFpgaUartFromPC),
        .oUartData(uartData)
    )

    clk_wiz_0 clk_instance(
        .clk_in1(clock),
        .clk_out1(cpu_clk),
        .clk_out2(upgclk)
    );

 
    //Instruction Fetch   
    Ifetc32 if_instance(
        .Instruction(instruction),
        .branch_base_addr(branch_base_addr),
        .Addr_result(addr_result),
        .Read_data_1(read_data_1),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jmp(Jmp),
        .Jal(Jal),
        .Jr(Jr),
        .Zero(Zero),
        .clock(cpu_clk),
        .reset(not_uart_rst),
        .link_addr(link_addr)
    );
    
    

    
    
    
    //CPU Decoder
    decode32 decode_instance(
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .Instruction(instruction),
        .mem_data(mem_data),
        .ALU_result(alu_result),
        .Jal(Jal),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .RegDst(RegDst),
        .Sign_extend(sign_extend),
        .clock(cpu_clk),
        .reset(not_uart_rst),
        .opcplus4(PC_plus_4)
    );
    
    

    
    
    //CPU Controller
    control32 control_instance(
        .Opcode(opcode),
        .Function_opcode(function_opcode),
        .Jr(Jr),
        .RegDST(RegDst),
        .ALUSrc(ALUSrc),
        .MemorIOtoReg(MemorIOtoReg),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jmp(Jmp),
        .Jal(Jal),
        .I_format(I_format),
        .Sftmd(Sftmd),
        .ALUOp(ALUop),
        .Alu_resultHigh(alu_resultHigh),
        .MemRead(memRead),
        .MemWrite(memWrite),
        .IORead(ioRead),
        .IOWrite(ioWrite)
    );
    
    
    
    //CPU ALU
    executs32 alu_instance(
        .Read_data_1(read_data_1),
        .Read_data_2(read_data_2),
        .Sign_extend(sign_extend),
        .Function_opcode(function_opcode),
        .Exe_opcode(opcode),
        .ALUOp(ALUop),
        .Shamt(shamt),
        .Sftmd(Sftmd),
        .ALUSrc(ALUSrc),
        .I_format(I_format),
        .Jr(Jr),
        .Zero(Zero),
        .regALU_Result(alu_result),
        .Addr_Result(addr_result),
        .PC_plus_4(PC_plus_4)
    );
    
    
    
    dmemory32 dm_instance(
        .clock(cpu_clk),
        .memWrite(memWrite),
        .address(addr_out),
        .writeData(writeData),
        .readData(readData)
    );
    
    
    
    MemOrIO morio_instance(
        .mRead(memRead),
        .mWrite(memWrite),//memWrite
        .ioRead(ioRead),//ioRead)
        .ioWrite(ioWrite),//ioWrite
        .addr_in(addr_result),
        .addr_out(addr_out),
        .m_rdata(readData),
        .io_rdata(io_rdata),
        .r_wdata(mem_data),
        .r_rdata(read_data_2),
        .write_data(writeData),
        .SwitchCtrl(SwitchCtrl),
        .LEDCtrl(LEDCtrl),
        //.UartCtrl(UartCtrl)
        // in memorio: assign UartCtrl = (ioRead == 1'b1 && addr_in[7:4] == 4'h9) ? 1'b1 : 1'b0;
    );

    wire[15:0] switch_wdata;
    Switch switch(
        .switclk(clock),
        .switrst(not_uart_rst),
        .switcs(SwitchCtrl),
        .switread(ioRead),
        .switch_wdata(switch_wdata),
        .switch_rdata(Switches)
    );    
    assign io_rdata = UartCtrl ? uartData : switch_wdata;


    ledDriver led(
        .ledclk(clock),
        .ledrst(not_uart_rst),
        .ledwrite(ioWrite),//ioWrite
        .ledcs(LEDCtrl),//LEDCtrl
        .ledaddr(addr_out[1:0]),
        .ledinputdata(writeData[15:0]),
        // .ledinputdata(16'b0000000000000100),
        .ledout(Lights)
    );
    

endmodule