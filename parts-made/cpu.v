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
    wire            RegDest;
    wire            AluSrcA;
    wire            EPCWrite;
    wire            IorD;
    wire            HIWrite;
    wire            LOWrite;
    wire            DivMult;
    wire            MultOverflow;         
    wire            ByZero;   
    wire    [3:0]   WriteSrc;
    wire    [3:0]   PCSource;
    wire    [3:0]   AluSrcB;
    wire    [3:0]   Exception;
    wire    [2:0]   ShiftControl;
    wire            ABWrite;
    wire            ALUoutWrite;
    
        // alu wires
    wire    [2:0]   ALUControl;
    wire            ALUoverflow;
    wire            Negative;
    wire            Zero;
    wire            Equal;
    wire            Greater;
    wire            Less;

    wire            ExceptionOcurred; // todo: exception logic




    // data wires
    wire    [5:0]       OPCODE;
    wire    [4:0]       RS;
    wire    [4:0]       RT;
    wire    [4:0]       RD;
    wire    [15:0]      IMMEDIATE;
    wire    [5:0]       SHAMT;
    wire    [5:0]       FUNCT;
    wire    [25:0]      OFFSET;
    assign  RD      = IMMEDIATE[15:11];
    assign  SHAMT   = IMMEDIATE[10:6];
    assign  FUNCT   = IMMEDIATE[5:0];
    assign  OFFSET  = {RS, RT, IMMEDIATE};

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
    wire    [3:0]       PCjump;
    assign  PCjump = PC[31:28];

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
    wire    [31:0]      JumpShiftLeftout;
    wire    [31:0]      ShiftLeftout;
    wire    [31:0]      HIout;
    wire    [31:0]      DivMultHIout;
    wire    [31:0]      DivMultLOout;
    wire    [31:0]      DivHIout;
    wire    [31:0]      MultHIout;
    wire    [31:0]      DivLOout;
    wire    [31:0]      MultLOout;




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
        .Instr15_0(IMMEDIATE)
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
        ALUoverflow,
        Negative,
        Zero,
        Equal,
        Greater,   
        Less
    );


    // Shift Reg
    RegDesloc   shift_reg(
        clk,
        reset,
        ShiftControl,
        SHAMT,
        Bout,
        Shiftout
    );

    // Sign Extend

    sign_ext_16b SignExt(
        IMMEDIATE, 
        SignExtout
    );

    // Shift lefts
    jump_Shiftleft2 JumpShiftLeft(
        OFFSET,
        PCjump,
        JumpShiftLeftout
    );

    shiftleft2      shiftleft(
        SignExtout,
        ShiftLeftout
    );

    // Divisor

    Div Div(
        AluSrcA,
        AluSrcB,
        DivHIout,
        DIvLOout,
        ByZero
    );

    // Multiplicador

    Mult Mult(
        AluSrcA,
        AluSrcB,
        MultOverflow,
        MultHIout,
        MultLOout
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
        ALUoutWrite,
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

    Registrador HI(
        clk,
        reset,
        HIWrite,
        DivMultHIout, 
        HIout
    );

    Registrador LO(
        clk,
        reset,
        LOWrite
        DivMultLOout, 
        LOout;

    )

    //multiplexers

    mux_writedata m_writedata(
        MemToReg,
        WriteSrcout,  
        MemRegout,       // semi desisti do byte
        WriteData
    );

    mux_writereg m_writereg(
        RegDest,
        RT,
        IMMEDIATE,
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
        ShiftLeftout,        
        AluSrcBout
    );

    mux_IorD    m_IorD(
        IorD,
        PCout,
        MemExcpout,       
        IorDout
    );

    mux_pcsource    m_PCSource(
        PCSource,
        ALUResult,
        ALUout,
        JumpShiftLeftout,    
        EPCout,
        PCSourceout
    );

    mux_exception   m_exception(
        Exception,
        ALUout,
        MemExcpout
    );

    mux_writesrc    m_writesrc(
        WriteSrc,
        ALuout,
        HIout, 
        LOout, 
        WriteSrcout
    );

    mux_pcerror m_pcexception(
        ExceptionOcurred,
        PCSourceout,
        EPCout,
        PCin
    );

    mux_DivMultHI m_DivMultHI(
        DivMult,
        DivHIout,
        MultHIout,
        DivMultHIout
    );

    mux_DivMultLO m_DivMultLO(
        DivMult,
        DivLOout,
        MultLOout,
        DivMultLOout
    );


endmodule