module cpu(
    input wire clk,
    input wire reset
);


    //control wires

    wire            PCwrite;
    wire            MemWrite;
    wire            IRWrite;
    wire            RegWrite;
    wire            MemToReg;
    wire            RegDest,
    
    // alu wires
    wire    [2:0]   ALUControl,
    wire            Overflow,
    wire            Negativo,
    wire            Zero,
    wire            Igual,
    wire            Maior,
    wire            Menor






    // data wires
    wire    [5:0]       OPCODE;
    wire    [4:0]       RS;
    wire    [4:0]       RT;
    wire    [15:0]      OFFSET;

    wire    [4:0]       WriteReg;
    wire    [31:0]      WriteData;
    wire    [31:0]      ReadData1;
    wire    [31:0]      ReadData2;


    wire    [31:0]      ALUResult;
    wire    [31:0]      ALUout;
    wire    [31:0]      MemtoIR;

    wire    [31:0]      PCout;
    wire    [31:0]      PCin;
    wire    [31:0]      PCSrcout;
    wire    [31:0]      WriteSrcout;
    wire    [31:0]      Byteout;



    // PC
    Registrador PC_(
        .clk(clk),
        .Reset(reset),
        .Load(PCwrite),
        .Entrada(PCin), //
        .Saida(PCout) // TODO: ADD PCSOURCE MUX
    );


    // memory
    Memoria mem_(
        .Address(PCout),
        .Clock(clk),
        .Wr(MemWrite),
        .Datain(ALUout),
        .Dataout(MemtoIR)
    );


    // instruction register
    Instr_Reg ir_(
        .clk(clk);
        .Reset(reset),
        .Load_ir(IRWrite),
        .Entrada(MemtoIR),
        .Instr31_26(OPCODE),
        .Instr25_21(RS),
        .Instr20_16(RT),
        .Instr15_0(OFFSET)
    ); 

    // Register Bank 
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

    // ALU

    Ula32   ALU(
        Aout,       // TODO make register A
        Bout,       //TODO make register B
        ALUControl, 
        ALUResult,
        Overflow,
        Negativo,
        Zero,
        Igual,
        Maior,
        Menor
    );

    //Registers in cpu

    Registrador ALU_out(
        clk,
        reset,
        1,
        ALUResult,
        ALUout
    );

    Registrador A(
        clk,
        reset,
        1,
        ReadData1,
        Aout
    );

    Registrador B(
        clk,
        reset,
        1,
        ReadData2,
        Bout
    );
    
    //multiplexers

    mux_writedata m_writedata(
        MemToReg,
        WriteSrcout,  // TODO: MAKE WRITESRCMUX
        Byteout,       // TODO: MAKE BYTE_MUX
        WriteData
    );

    mux_writereg m_writereg(
        RegDest,
        RT,
        OFFSET,
        WriteReg
    );







endmodule