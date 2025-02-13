module cpu(
    input wire clk,
    input wire reset
);


    //control wires

    wire            pc_w;
    wire            mem_w;
    wire            ir_w;
    wire            m_wreg;
    wire            RegWrite;
    wire    [4:0]   PCsource;
    wire            over_mult;
    wire            over_sum;
    wire            not_a_instruction;
    wire            exception;
    wire            MemToReg;






    // data wires
    wire    [5:0]       OPCODE;
    wire    [4:0]       RS;
    wire    [4:0]       RT;
    wire    [15:0]      OFFSET;

    wire    [4:0]       WriteReg;
    wire    [31:0]      WriteData;
    wire    [31:0]      ReadData1;
    wire    [31:0]      ReadData2;


    wire    [31:0]      alu_result;
    wire    [31:0]      pc_out;
    wire    [31:0]      mem_to_ir;

    wire    [31:0]      pc_in;
    wire    [31:0]      pc_src_out;



    Registrador PC_(
        .clk(clk),
        .Reset(reset),
        .Load(pc_w),
        .Entrada(pc_in),
        .Saida(pc_out)
    );

    Registrador ALU_out();

    Memoria mem_(
        .Address(PC_out),
        .Clock(clk),
        .Wr(MemWrite),
        .Datain(alu_out),
        .Dataout(mem_to_ir)
    );

    // instruction register
    Instr_Reg ir_(
        .clk(clk);
        .Reset(reset),
        .Load_ir(IRWrite),
        .Entrada(mem_to_ir),
        .Instr31_26(OPCODE),
        .Instr25_21(RS),
        .Instr20_16(RT),
        .Instr15_0(OFFSET)
    ); 

    mux_writedata m_writedata(
        MemToReg,
        write_src_mux_out,  // TODO: MAKE WRITESRCMUX
        byte_mux_out,       // TODO: MAKE BYTE_MUX
        WriteData
    );

    mux_writereg m_writereg(
        RegDest,
        RT,
        OFFSET,
        WriteReg
    );

    Banco_reg reg_base(
        clk,
        reset,
        RegWrite,
        RS,
        RT,
        WriteReg,
        WriteData,
        ReadData1,
        ReadData2
    );






endmodule