module cpu(
    input wire clk,
    input wire reset
);


    // wires

    wire            doDiv;
    wire            RTE;
    wire            TempWrite;
    wire            PCWrite;
    wire            MemWrite;
    wire            MemRead;
    wire            IRWrite;
    wire            RegWrite;
    wire    [3:0]   MemToReg;
    wire    [3:0]   RegDest;
    wire    [3:0]   ALUSrcA;
    wire            EPCWrite;
    wire            IorD;
    wire            HIWrite;
    wire            LOWrite;
    wire            DivMult;
    wire            MultOverflow;         
    wire            ByZero;   
    wire    [3:0]   WriteSrc;
    wire    [3:0]   PCSource;
    wire    [3:0]   ALUSrcB;
    wire    [3:0]   Exception;
    wire    [2:0]   ShiftControl;
    wire            ABWrite;
    wire            ALUoutWrite;
    wire    [3:0]   ShiftSourceA;
    wire    [3:0]   ShiftSourceB;
    wire    [3:0]   MemWriteSrc;

            // ALU wires
    wire    [2:0]   ALUControl;
    wire            ALUoverflow;
    wire            Negative;
    wire            Zero;
    wire            Equal;
    wire            Greater;
    wire            Less;

    wire            ExceptionOcurred; // todo: exception logic

    assign ABWrite = 1'b1;
    


    // data wires
    wire    [5:0]       OPCODE;
    wire    [4:0]       RS;
    wire    [4:0]       RT;
    wire    [4:0]       RD;
    wire    [15:0]      IMMEDIATE;
    wire    [4:0]       SHAMT;
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

    wire    [31:0]        SLTout;
    wire    [31:0]      ALUResult;
    wire    [31:0]      ALUout;
    wire    [31:0]      Memout;
    wire    [7:0]       MemByte;
    wire    [31:0]      MemExtOut;

    wire    [31:0]      JALAddress;
    wire    [31:0]      PCout;
    wire    [31:0]      PCin;
    wire    [31:0]      PCSrcout;
    wire    [3:0]       PCjump;
    assign  PCjump = PCout[31:28];
    assign JALAddress = PCout + 4;

    wire    [31:0]      RTEout;
    wire    [31:0]      Aout;
    wire    [31:0]      Bout;
    wire    [31:0]      WriteSrcout;
    wire    [31:0]      Byteout;
    wire    [31:0]      Shiftout;
    wire    [31:0]      ALUSrcAout;
    wire    [31:0]      ALUSrcBout;
    wire    [31:0]      SignExtout;
    wire    [31:0]      MemRegout;
    wire    [31:0]      EPCout;
    wire    [31:0]      MemExcpout;
    wire    [31:0]      IorDout;
    wire    [31:0]      PCSourceout;
    wire    [31:0]      JumpShiftLeftout;
    wire    [31:0]      ShiftLeftout;
    wire    [31:0]      HIout;
    wire    [31:0]      LOout;
    wire    [31:0]      DivMultHIout;
    wire    [31:0]      DivMultLOout;
    wire    [31:0]      DivHIout;
    wire    [31:0]      MultHIout;
    wire    [31:0]      DivLOout;
    wire    [31:0]      MultLOout;
    wire    [4:0]       ShiftAout;
    wire    [31:0]      ShiftBout;
    wire    [31:0]      Tempout;
    assign MemByte = MemRegout[7:0];

    // Control Unit

    control_unit ControlUnit(
        .clk(clk),
        .doDiv(doDiv),
        .RTEsig(RTE),
        .reset(reset),
        .ALUoverflow(ALUoverflow),
        .Negativo(Negative),
        .Zero(Zero),
        .Igual(Equal),
        .Maior(Greater),
        .Menor(Less),
        .Multoverflow(Multoverflow),
        .DivByZero(ByZero),
        .OPCODE(OPCODE),
        .FUNCT(FUNCT),
        .MemWrite(MemWrite),
        .PCWrite(PCWrite),
        .MemRead(MemRead),
        .IRWrite(IRWrite),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .RegDest(RegDest),
        .ALUSrcA(ALUSrcA),
        .EPCWrite(EPCWrite),
        .ALUSrcB(ALUSrcB),
        .IorD(IorD),
        .HIWrite(HIWrite),
        .LOWrite(LOWrite),
        .DivMult(DivMult),
        .ALUoutWrite(ALUoutWrite),
        .ExceptionOcurred(ExceptionOcurred),
        .WriteSrc(WriteSrc),
        .PCSource(PCSource),
        .Exception(Exception),
        .ShiftControl(ShiftControl),
        .ALUControl(ALUControl),
        .ShiftSourceA(ShiftSourceA),
        .ShiftSourceB(ShiftSourceB),
        .out_reset(reset),
        .TempWrite(TempWrite)
    );


    // PC
    Registrador PC_(
        .clk(clk),
        .Reset(reset),
        .Load(PCWrite),
        .Entrada(PCin), // MAKE PCin MUX
        .Saida(PCout)
    );


    // memory
    Memoria mem_(
        .Address(IorDout),
        .Clock(clk),
        .Wr(MemWrite),
        .Datain(Bout),
        .Dataout(Memout)
    );


    // instruction register
    Instr_Reg ir_(
        .clk(clk),
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
        ALUSrcAout,      
        ALUSrcBout,     
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
        ShiftAout,
        ShiftBout,
        Shiftout
    );

    // Sign Extend

    sign_ext_16b SignExt16(
        IMMEDIATE, 
        SignExtout
    );

    sign_ext_24b SignExt24(
        MemByte,
        MemExtOut
    );

    sign_ext_31b SignExt31(
        Less,
        SLTout
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
        clk,
        ALUSrcAout,
        ALUSrcBout,
        doDiv,
        DivHIout,
        DivLOout,
        ByZero
    );

    // Multiplicador

    Mult Mult(
        ALUSrcAout,
        ALUSrcBout,
        MultOverflow,
        MultHIout,
        MultLOout
    );

    //Registers in cpu


    Registrador TempRegister(
        clk,
        reset,
        TempWrite,
        WriteSrcout,
        Tempout
    );

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
        ABWrite,
        ReadData1,
        Aout
    );

    Registrador B(
        clk,
        reset,
        ABWrite,
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
        LOWrite,
        DivMultLOout, 
        LOout
    );

    //multiplexers

    mux_writedata m_writedata(
        MemToReg,
        Tempout,  
        MemRegout,       
        MemExtOut,
        JALAddress,
        WriteData
    );

    mux_writereg m_writereg(
        RegDest,
        RT,
        IMMEDIATE,
        WriteReg
    );

    mux_ALUA    m_ALUsrcA(
        ALUSrcA,
        PCout,
        Aout,
        Bout,
        ALUSrcAout
    );

    mux_ALUB    m_ALUsrcB(
        ALUSrcB,
        Bout,
        SignExtout,        
        ShiftLeftout,        
        ALUSrcBout
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
        ALUout,
        HIout, 
        LOout, 
        Shiftout,
        SLTout,
        WriteSrcout
    );

    mux_rte     m_rte(
        RTE,
        PCSourceout,
        EPCout,
        RTEout
    );

    mux_pcerror m_pcexception(
        ExceptionOcurred,
        MemExtOut,
        RTEout, 
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

    mux_ShiftA  m_ShiftA(
        ShiftSourceA,
        SHAMT,
        Aout,
        ShiftAout
    );
    mux_ShiftB  m_shiftB(
        ShiftSourceB,
        Bout,
        IMMEDIATE,
        ShiftBout
    );


endmodule