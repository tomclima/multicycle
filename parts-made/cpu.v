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
    wire    [31:0]      SignExt;
    wire    [31:0]      MemRegout;
    wire    [31:0]      EPCout;



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

    mux_aluA    m_ALUsrcA(
        AluSrcA,
        PCout,
        Aout,
        ALUsrcAout
    );

    mux_aluB    m_ALUsrcB(
        AluSrcB,
        Bout,
        SignExt,        // TODO: ADD SIGN EXT MODULE
        ShiftL2,        // TODO: MAKE SHift Left 2 module
        AluSrcBout
    );






endmodule