module cpu(
    input wire clk,
    input wire reset
);


    //control wires

    wire            PCwrite;
    wire            MemWrite;
    wire            MemRead;
    wire            IRWrite;
    wire            RegWrite;
    wire            MemToReg;
    wire            RegDest,
    wire    [2:0]   ShiftControl;
    wire            AluSrcA;
    wire    [3:0]   AluSrcB;
    wire            EPCWrite;
    wire            IorD;
    wire    [3:0]   PCSource;
    wire            WriteSrc;
    
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
    wire    [31:0]      Memout;

    wire    [31:0]      PCout;
    wire    [31:0]      PCin;
    wire    [31:0]      PCSrcout;
    wire    [31:0]      WriteSrcout;
    wire    [31:0]      Byteout;
    wire    [31:0]      Shiftout;
    wire    [31:0]      ALUsrcAout;
    wire    [31:0]      AluSrcBout;
    wire    [31:0]      SignExtout;
    wire    [31:0]      MemRegout;
    wire    [31:0]      EPCout;
    wire    [31:0]      MemExcpout;
    wire    [31:0]      IorDout;
    wire    [31:0]      PCSourceout;



    // PC
    Registrador PC_(
        .clk(clk),
        .Reset(reset),
        .Load(PCwrite),
        .Entrada(PCin), // MAKE PCin MUX
        .Saida(PCout)
    );


    // memory
    Memoria mem_(
        .Address(IorDout),
        .Clock(clk),
        .Wr(MemWrite),
        .Datain(ALUout),
        .Dataout(Memout)
    );


    // instruction register
    Instr_Reg ir_(
        .clk(clk);
        .Reset(reset),
        .Load_ir(IRWrite),
        .Entrada(Memout),
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
        ALUsrcAout,      
        AluSrcBout,     
        ALUControl, 
        ALUResult,
        Overflow,
        Negativo,
        Zero,
        Igual,
        Maior,   
        Menor
    );


    // Shift Reg
    RegDesloc   shift_reg(
        clk,
        reset,
        ShiftControl,
        OFFSET[10:6],
        Bout,
        Shiftout
    );

    // Sign Extend

    sign_ext_16b SignExt(
        OFFSET, 
        SignExtout
    );


    //Registers in cpu

    Registrador MemDataRegister(
        clk,
        reset,
        MemRead,
        Memout,
        MemRegout
    );

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
    
    Registrador EPC(
        clk,
        reset,
        EPCWrite,
        ALUout,
        EPCout
    );

    //multiplexers

    mux_writedata m_writedata(
        MemToReg,
        WriteSrcout,  
        Byteout,       // TODO: MAKE BYTE_MUX
        WriteData
    );

    mux_writereg m_writereg(
        RegDest,
        RT,
        OFFSET,
        WriteReg
    );

    mux_aluA    m_ALUsrcA(
        AluSrcA,
        PCout,
        Aout,
        ALUsrcAout
    );

    mux_aluB    m_ALUsrcB(
        AluSrcB,
        Bout,
        SignExtout,        
        ShiftL2,        // TODO: MAKE SHift Left 2 module
        AluSrcBout
    );

    mux_IorD    m_IorD(
        IorD,
        PCout,
        MemExcpout,       // TODO: MAKE MemExcp multiplexer
        IorDout
    );

    mux_pcsource    m_PCSource(
        PCSource,
        ALUResult,
        ALUout,
        JumpAddress,    // TODO: MAKE shift left 2 and concatenation with pc
        EPCout,
        PCSourceout
    );

    mux_writereg    m_WriteSrc(
        WriteSrc,
        RS,
        OFFSET,
        WriteSrcout
    );







endmodule