module control_unit(
    input wire                  clk,
    input wire                  reset,
    
    // flags
    input wire                  ALUoverflow,
    input wire                  Negativo,
    input wire                  Zero,
    input wire                  Igual,
    input wire                  Maior,
    input wire                  Menor,
    input wire                  Multoverflow,
    input wire                  DivByZero,

    // OPCODE
    input wire      [5:0]       OPCODE,
    
    // FUNCT

    input wire      [5:0]       FUNCT,
    
    //CONTROL SIGNALS

    output reg                  RTEsig,
    output reg                  MemWrite,
    output reg                  PCWrite,
    output reg                  MemRead,
    output reg                  IRWrite,
    output reg                  RegWrite,
    output reg      [3:0]       MemToReg,
    output reg      [3:0]       RegDest,
    output reg      [3:0]       ALUSrcA,
    output reg                  EPCWrite,
    output reg                  IorD,
    output reg                  HIWrite,
    output reg                  LOWrite,
    output reg                  DivMult,
    
    output reg                  ALUoutWrite,
    output reg                  ExceptionOcurred,
    output reg                  TempWrite,
    output reg                  doDiv,
    // CONTROL VECTORS

    output reg     [3:0]        WriteSrc,
    output reg     [3:0]        PCSource,
    output reg     [3:0]        ALUSrcB,
    output reg     [3:0]        Exception,
    output reg     [2:0]        ShiftControl,
    output reg     [2:0]        ALUControl,
    output reg     [3:0]        ShiftSourceA,
    output reg     [3:0]        ShiftSourceB,

    // reset signal
    output reg                  out_reset
);

// STATEs

    parameter RESET      =  0;
    parameter READINST   =  1;
    parameter PC_INC     =  2;
    parameter DECODE     =  3;
    parameter READ_REGBANK = 4;
    parameter SLT        =  5;
    parameter SUB        =  7;
    parameter ADD        =  8;
    parameter AND        =  9;
    parameter OR         = 11;
    parameter DIV        = 13;
    parameter MULT       = 14;
    parameter JR         = 15;
    parameter SAVEPC     = 16;
    parameter LOADSHFT   = 25;
    parameter LOADSHFTV  = 17;
    parameter SLLV       = 21;
    parameter SRAV       = 18;
    parameter SRA        = 19;
    parameter SRL        = 20;
    parameter SLL        = 22;
    parameter MFHI       = 23;
    parameter MFLO       = 24;
    parameter SAVEREGRD  = 26;
    parameter BREAK      = 27;
    parameter SAVEPCBK   = 06;
    parameter RTE        = 28;
    parameter LOADA      = 29;
    parameter LOADB      = 30;
    parameter ATOB       = 31;
    parameter BTOA       = 32;
    parameter ADDI       = 33;
    parameter ADDIU      = 34;
    parameter SLTI       = 35;
    parameter DIVM       = 36;
    parameter LOADSLUI   = 12; 
    parameter LUI        = 37;
    parameter SAVEREGRT  = 53;
    parameter BRNCHCALC  = 38;
    parameter BEQ        = 39;
    parameter BNE        = 40;
    parameter BLE        = 41;
    parameter BGT        = 42;
    parameter CONDSAVEPC = 43;
    parameter MEMOCALC   = 6;
    parameter SW         = 44;
    parameter READMEM    = 45;
    parameter LW         = 46;
    parameter LH         = 47;
    parameter LB         = 48;
    parameter SH         = 49;
    parameter SB         = 50;
    parameter JUMP       = 51;
    parameter JAL        = 52;
    parameter EXCEPTION   = 54;
    parameter INVALIDOP  = 55;
    parameter OVERFLOW   = 56;
    parameter DIVBY0     = 57;
    parameter SAVEHILO   = 58;

    // R instructions
    parameter R_OPCODE      = 6'b000000;

    // FUNCTS
    parameter ADD_FUNCT     = 6'b100000;
    parameter AND_FUNCT     = 6'b100100;
    parameter DIV_FUNCT     = 6'b011010;
    parameter MULT_FUNCT    = 6'b011000;
    parameter JR_FUNCT      = 6'b001000;
    parameter MFHI_FUNCT    = 6'b010000;
    parameter MFLO_FUNCT    = 6'b010010;
    parameter SLL_FUNCT     = 6'b000000;
    parameter SLT_FUNCT     = 6'b101010;
    parameter SRA_FUNCT     = 6'b000011;
    parameter SRAV_FUNCT    = 6'b000111;
    parameter SLLV_FUNCT    = 6'b000100;
    parameter SRL_FUNCT     = 6'b000010;

    parameter SUB_FUNCT     = 6'b100010;
    parameter DIVM_FUNCT    = 6'b000101;


    // I instructions
    parameter RESET_OPCODE  = 6'b111111;
    parameter ADDI_OPCODE   = 6'b001000;
    parameter BEQ_OPCODE    = 6'b000100;
    parameter BNE_OPCODE    = 6'b000101;
    parameter ADDM_OPCODE   = 6'b000001;
    parameter LB_OPCODE     = 6'b100000;
    parameter LUI_OPCODE    = 6'b001111;
    parameter LW_OPCODE     = 6'b100011;
    parameter SB_OPCODE     = 6'b101000;
    parameter SW_OPCODE     = 6'b101011;


    // J instructions
    parameter JUMP_OPCODE = 6'b000010;
    parameter JAL_OPCODE = 6'b000011;

    
    wire overflowflag;
    assign overflowflag = ALUoverflow || Multoverflow;
    assign ALUoutWrite = 1'b1;

    integer COUNTER = 0;
    integer STATE = 0;

    initial begin
    
    out_reset = 1'b1;

    end

always @(posedge clk, reset) begin
        if( reset == 1'b1 ) 
        begin
            if(STATE == RESET) begin
                STATE = 0; 
                COUNTER = 0;
                out_reset = 1'b0;
            end
            else begin
                out_reset = 1'b0;
                COUNTER = 0;
                STATE = READINST;
            end

        end
        else
        begin
            // TRANSIÃÃO ENTRE OS STATES
            if( STATE == RESET )
            begin
                if(COUNTER == 0) COUNTER = 2;  //para esperar um ciclo ainda no reset, para gravar na memÃ³ria
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) begin
                    out_reset = 1'b0;
                    STATE = READINST;
                end
            end
            else if(overflowflag)          STATE = OVERFLOW;
            else if(STATE == READINST) 
            begin 
                if(COUNTER == 0) COUNTER = 3;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0)  STATE = PC_INC;
            end
            else if(STATE == PC_INC)   STATE = DECODE;
            else if(STATE == DECODE)
            begin
                //INSTRUÃÃES R
                if(OPCODE == 6'b000000)
                begin
                         if(FUNCT == MFHI_FUNCT) STATE = MFHI;    //mfhi  0x10
                    else if(FUNCT == MFLO_FUNCT) STATE = MFLO;    //mflo  0x12
                    else if(FUNCT == SLT_FUNCT) STATE = SLT;     //slt   0x2a
                    else if(FUNCT == SUB_FUNCT) STATE = SUB;     //sub   0x22
                    else if(FUNCT == ADD_FUNCT) STATE = ADD;     //add   0x20
                    else if(FUNCT == AND_FUNCT) STATE = AND;     //and   0x24
                    else if(FUNCT == DIV_FUNCT) STATE = DIV;     //div   0x1a
                    else if(FUNCT == MULT_FUNCT) STATE = MULT;    //mul   0x18
                    else if(FUNCT == JR_FUNCT) STATE = JR;      //JR    0x8
                    else if(FUNCT == SRA_FUNCT) STATE = LOADSHFT;//SRA   0x3
                    else if(FUNCT == SLL_FUNCT) STATE = LOADSHFT;//SLL   0x0
                    else if(FUNCT == DIVM_FUNCT) STATE = DIVM;     //DIVM  0x1
                    else if(FUNCT == SRAV_FUNCT ) STATE = LOADSHFTV;//SRAV  0x7                  TESTBENCH
                    else if(FUNCT == SLLV_FUNCT ) STATE = LOADSHFTV;//SLLV  0x4                  TESTBENCH
                    else if(FUNCT == SRL_FUNCT) STATE = LOADSHFT;//SRL   0x2                   TESTBENCH
                    else STATE = INVALIDOP;
                end
                // INSTRUÃÃES I
                else if(OPCODE == ADDI_OPCODE) STATE = ADDI;     //ADDI  0x8
                else if(OPCODE == LUI_OPCODE) STATE = LOADSLUI; //LUI   0xf
                else if(OPCODE == BEQ_OPCODE) STATE = BRNCHCALC;//BEQ   0x4
                else if(OPCODE == BNE_OPCODE) STATE = BRNCHCALC;//BNE   0x5
                else if(OPCODE == LW_OPCODE) STATE = MEMOCALC; //LW    0x23
                else if(OPCODE == LB_OPCODE) STATE = MEMOCALC; //LB    0x20
                else if(OPCODE == SW_OPCODE) STATE = MEMOCALC; //SW    0x2b
                else if(OPCODE == SB_OPCODE) STATE = MEMOCALC; //SB    0x28
                else if(OPCODE == JUMP_OPCODE) STATE = JUMP;     //J     0x2            TESTBENCH
                else if(OPCODE == JAL_OPCODE) STATE = JAL;      //JAL   0x3            TESTBENCH
                else STATE = INVALIDOP;
            end
            // INSTRUÃÃES R - TRANSIÃÃES
            else if(STATE == SLT || STATE == ADD || STATE == AND || STATE == SUB || STATE == MFHI || STATE == MFLO) begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = SAVEREGRD;
            end
            else if(STATE == JR)      STATE = SAVEPC;
            else if(STATE == SAVEPC)  STATE = READINST;
            else if(STATE == SAVEPCBK)STATE = READINST;
            else if(STATE == LOADSHFT)
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0)
                begin
                         if(FUNCT == SRA_FUNCT) STATE = SRA;   //SRA   0x3
                    else if(FUNCT == SLL_FUNCT) STATE = SLL;   //SLL   0x0
                    else if(FUNCT == SRL_FUNCT) STATE = SRL;   //SRL   0x2
                    else STATE = INVALIDOP;
                end
            end
            
            else if(STATE == LOADSHFTV)
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0)
                begin
                    if(FUNCT == 6'b000100) STATE = SLLV;  //SLLV  0x4
                    else if(FUNCT == 6'b000111) STATE = SRAV;  //SRAV  0x7
                    else STATE = INVALIDOP;
                    end
                end
            else if(STATE == SLLV || STATE == SRAV || STATE == SRL || STATE == SRA || STATE == SLL) //todos os shift tipo R
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = SAVEREGRD;
            end
            else if(STATE == SAVEREGRD) begin
                if (COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER -1; 
                if(COUNTER == 0) STATE = READINST;
            
            end
             else if(STATE == SAVEHILO) STATE = READINST;
            

            else if(STATE == DIV || STATE == MULT)
            begin
                if(COUNTER == 0) COUNTER = 2; //espera 32 ciclos para completar a divisÃ£o/multiplicaÃ§Ã£o
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = SAVEHILO;
                if(DivByZero)begin COUNTER = 0; STATE = DIVBY0; end
                if(Multoverflow) begin COUNTER = 0; STATE = OVERFLOW; end
            end

            // INSTRUÃÃES I - TRANSIÃÃES
            else if(STATE == ADDI) begin    
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER -1;
                if(COUNTER == 0) STATE = SAVEREGRT;
            end
            // else if(STATE == ADDIU)   STATE = SAVEREGRT;
            // else if(STATE == SLTI)    STATE = SAVEREGRT;
            else if(STATE == LOADSLUI)
            begin
                 if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = LUI;
            end
            else if(STATE == LUI)     //STATE = SAVEREGRT;
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = SAVEREGRT;
            end
            else if(STATE == SAVEREGRT) begin
                if (COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER -1; 
                if(COUNTER == 0) STATE = READINST;
            
            end
            else if(STATE == DIVM)
            begin 
                if(COUNTER == 0) COUNTER = 34;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = READINST;
                if(DivByZero)begin COUNTER = 0; STATE = DIVBY0; end
            end
            else if(STATE == BRNCHCALC)
            begin
                     if(OPCODE == 6'b000100) STATE = BEQ;//BEQ   0x4
                else if(OPCODE == 6'b000101) STATE = BNE;//BNE   0x5
                // else if(OPCODE == 6'b000110) STATE = BLE;//BLE   0x6
                // else if(OPCODE == 6'b000111) STATE = BGT;//BGT   0x7
            end
            else if(STATE == BEQ)        STATE = CONDSAVEPC;
            else if(STATE == BNE)        STATE = CONDSAVEPC;
            // else if(STATE == BLE)        STATE = CONDSAVEPC;
            // else if(STATE == BGT)        STATE = CONDSAVEPC;
            else if(STATE == CONDSAVEPC) STATE = READINST;
            else if(STATE == MEMOCALC)
            begin
                if(OPCODE ==  SW_OPCODE) STATE = SW;  // SW 0x2b
                else STATE = READMEM;  // SH/SB/LW/LH/LB
            end
            else if(STATE == READMEM) 
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0)
                begin
                         if(OPCODE == 6'b100011) STATE = LW;  //LW    0x23
                    else if(OPCODE == 6'b100000) STATE = LB;  //LB    0x20
                    else if(OPCODE == 6'b101000) STATE = SB;  //SB    0x28
                    // else if(OPCODE == 6'b100001) STATE = LH;  //LH    0x21
                    // else if(OPCODE == 6'b101001) STATE = SH;  //SH    0x29
                end
            end
            else if(STATE == LW)
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = READINST;
            end
            // else if(STATE == LH)// STATE = READINST;
            // begin
            //     if(COUNTER == 0) COUNTER = 2;
            //     COUNTER = COUNTER - 1;
            //     if(COUNTER == 0) STATE = READINST;
            // end
            else if(STATE == LB)// STATE = READINST;
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = READINST;
            end
            else if(STATE == SW) STATE = READINST;
            else if(STATE == SB) STATE = READINST;
            else if(STATE == LB) STATE = READINST;
            // else if(STATE == SH) STATE = READINST;
            // INSTRUÃÃES J - TRANSIÃÃO
            else if(STATE == JUMP) STATE = READINST;
            else if(STATE == JAL)  STATE = READINST;             
            // begin
            //     if(COUNTER == 0) COUNTER = 1;
            //     COUNTER = COUNTER - 1;
            //     if(COUNTER == 0) STATE = READINST;
            // end
            // TRATAMENTOS DE ERROS
            else if(STATE == EXCEPTION) // STATE = READINST;
            begin
                if(COUNTER == 0) COUNTER = 2;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = READINST;
            end
            else if(STATE == INVALIDOP) // STATE = EXCEPTION;
            begin
                if(COUNTER == 0) COUNTER = 6;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = EXCEPTION;
            end
            else if(STATE == DIVBY0)   // STATE = EXCEPTION;
            begin
                if(COUNTER == 0) COUNTER = 6;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = EXCEPTION;
            end
            else if(STATE == OVERFLOW)
            begin
                if(COUNTER == 0) COUNTER = 6;
                COUNTER = COUNTER - 1;
                if(COUNTER == 0) STATE = EXCEPTION;
            end
        end
    end


    parameter ALULOAD       = 3'b000; 
    parameter ALUADD       = 3'b001;
    parameter ALUSUB        = 3'b010;
    parameter ALUAND        = 3'b011;
    parameter ALUADD1       = 3'b100;
    parameter ALUNOT        = 3'b101;
    parameter ALUXOR        = 3'b110;
    parameter ALUCMP        = 3'b111;

    parameter SHIFTIDLE     = 3'b000;
    parameter SHIFTLOAD     = 3'b001;
    parameter SHIFTLEFT     = 3'b010;
    parameter SHIFTRIGHTL   = 3'b011;
    parameter SHIFTRIGHTA   = 3'b100;
    parameter SHIFTRIGHTROT = 3'b101;
    parameter SHIFTLEFTROT  = 3'b110;


        always @(STATE) begin
        
        doDiv = 1'b0;
        RTEsig = 1'b0;
        MemWrite = 1'b0;
        PCWrite = 1'b0;
        MemRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        RegDest = 3'b000;
        ALUSrcA = 4'b0000;
        EPCWrite = 1'b0;
        IorD = 1'b0;
        HIWrite = 1'b0;
        LOWrite = 1'b0;
        DivMult = 1'b0;
        TempWrite = 1'b0;
        
        ExceptionOcurred = 1'b0;

        MemToReg = 3'b000;
        WriteSrc = 3'b0;
        PCSource = 3'b0;
        ALUSrcB = 4'b0;
        Exception = 3'b0;
        ShiftControl = 2'b0;
        ALUControl = 2'b0;
        ShiftSourceA = 4'b0000;
        ShiftSourceB = 4'b0000;


        if(STATE == RESET)
        begin
            RegDest  = 3'b011; // seleciona o $29
            MemToReg = 3'b011; // seta o $29 como 227
            RegWrite = 1'b1;   // escreve no banco
        end
        else if(STATE == READINST)
        begin
            IorD    = 1'b0;    // seleciona o endereÃ§o do pc p/ o mux
            // Exception = 3'b000;
            MemRead = 1'b1; // memÃ³ria lÃª automaticamente 
            ALUSrcA = 4'b0000;   
            ALUSrcB = 4'b0001; 
            ALUControl = ALUADD;
        end
        else if(STATE == PC_INC)
        begin
            ALUSrcA = 4'b0000;   
            ALUSrcB = 4'b0001; 
            ALUControl = ALUADD;
            ExceptionOcurred = 1'b0;
            PCSource = 4'b0000;
            PCWrite = 1'b1;
            IRWrite = 1'b1; 
        end
        else if(STATE == DECODE)
        begin
            IRWrite = 1'b1; 
           // PCWrite = 1'b1;
            // PCWrite = 1'b1; // !!! Adicionado !!!
            // IRWrite = 1'b1; // !!! cuidado !!!
        end
        // INSTRUÃÃES R
        else if(STATE == SLT)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB  = 3'b000;
            WriteSrc = 4'b0100;
            TempWrite = 1'b1;
            ALUControl = ALUCMP;  // S = X comp Y
        end
        else if(STATE == SUB)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB  = 3'b000;
            ALUControl = ALUSUB; // S = X - Y
            WriteSrc = 4'b0000;
            TempWrite = 1'b1;
        end
        else if(STATE == ADD)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB = 4'b0000;
            ALUControl = ALUADD; // soma COM OVERFLOW
            WriteSrc = 4'b0000;
            TempWrite = 1'b1;
        end
        else if(STATE == AND)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB  = 3'b000;
            ALUControl = ALUAND;
            WriteSrc = 4'b0000;
            TempWrite = 1'b1;
        end
        // else if(STATE == OR)
        // begin
        //     ALUSrcA = 4'b0001;
        //     ALUSrcB = 3'b000;
        //     ALUControl = ALUOR;
        // end
        else if(STATE == DIV)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB  = 4'b0000;
            DivMult = 1'b0;
            HIWrite = 1'b1;
            LOWrite = 1'b1;
            doDiv = 1'b1;

        end
        else if(STATE == MULT)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB  = 4'b0000;
            DivMult = 1'b1;
            HIWrite = 1'b1;
            LOWrite = 1'b1;
        end
        else if(STATE == JR)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB  = 3'b000;
            ALUControl = ALULOAD;
            PCSource = 3'b001;
            ExceptionOcurred = 1'b0;
            PCWrite = 1'b1;
        end
        else if(STATE == SAVEPC)
        begin
            PCSource = 3'b001;
            PCWrite  = 1'b1;
        end
        else if(STATE == SAVEPCBK)
        begin
            PCSource = 3'b010;
            PCWrite  = 1'b1;
        end
        else if(STATE == LOADSHFT)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB  = 3'b000;
            ShiftSourceA = 4'b0000; 
            ShiftSourceB = 4'b0000; 
            ShiftControl = SHIFTLOAD;
        end
        else if(STATE == LOADSHFTV)
            begin
                ShiftSourceA = 4'b0001; 
                ShiftSourceB = 2'b00; 
                ShiftControl = SHIFTLOAD;
                
        end
        else if(STATE == SLLV)
         begin
            ShiftSourceA = 4'b0010;
            ShiftSourceB = 4'b0000; //
            ShiftControl = SHIFTLEFT;
            WriteSrc = 4'b0011;
            TempWrite = 1'b1;

        end
        else if(STATE == SRAV)
        begin
            ShiftSourceA = 4'b0010;
            ShiftControl = SHIFTRIGHTA;
            WriteSrc = 4'b0011;
            TempWrite = 1'b1;
        end
        else if(STATE == SRA)
        begin
            ShiftSourceA = 4'b0000;
            ShiftSourceB = 4'b0000;
            ShiftControl = SHIFTRIGHTA;
            WriteSrc = 4'b0011;
            TempWrite = 1'b1;
        end
        else if(STATE == SRL) 
         begin
            ShiftSourceA = 4'b0000;
            ShiftSourceB = 4'b0000;
            ShiftControl = SHIFTLEFTROT;
            WriteSrc = 4'b0011;
            TempWrite = 1'b1;

         end
        else if(STATE == SLL)
        begin

            ShiftSourceA = 4'b0000;
            ShiftSourceB = 4'b0000;
            ShiftControl = SHIFTLEFT;
            WriteSrc = 4'b0011;
            TempWrite = 1'b1;
        end
        else if(STATE == MFHI)
        begin
            RegWrite = 1'b0;
            MemToReg = 3'b000;
            WriteSrc = 4'b0001;
            RegDest  = 3'b001;
        end
        else if(STATE == MFLO)
        begin
            RegWrite = 1'b0;
            MemToReg = 3'b000;
            WriteSrc = 4'b010;
            RegDest  = 3'b001;
        end
        else if(STATE == SAVEREGRD)
        begin
            RegWrite = 1'b1; 
            RegDest = 3'b001;
            MemToReg = 3'b000;
        end
        else if(STATE == SAVEHILO) begin
            HIWrite = 1'b1;
            LOWrite = 1'b1;

         end

        else if(STATE == RTE)
        begin
             RTEsig = 1'b1;
             PCSource = 3'b100;
             PCWrite = 1'b1;
        end
  


        // INSTRUIÃÃES I
        else if(STATE == ADDI)
        begin
            ALUSrcA = 4'b0001;
            ALUSrcB = 4'b0010;
            WriteSrc = 4'b0000;
            TempWrite = 1'b1;
            ALUControl = ALUADD; //soma com overflow
        end

        else  if(STATE == LOADSLUI)          
        begin 
            ShiftSourceB = 4'b0001;
            ShiftControl = 3'b001;
        end
        else if(STATE == LUI)                   
        begin
            ShiftSourceA = 4'b0001; 
            ShiftControl = 3'b010;
            WriteSrc = 4'b0011;
            TempWrite = 1'b1;
            
        end
        else if(STATE == SAVEREGRT)
        begin
            MemToReg = 3'b000;
            RegWrite = 1'b1;
            RegDest = 3'b000;
        end


        else if(STATE == MEMOCALC)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD; // aluout informa o address 
        end
        else if(STATE == SW)
        begin
            IorD = 1'b1;
            Exception = 3'b000;

            MemWrite = 1'b1;

            ALUSrcA = 2'd1;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD;
        end
        else if(STATE == READMEM)
        begin
            IorD = 1'b1;
            Exception = 3'b000; //LÃª da memÃ³ria na pos calculada em MEMOCALC

            ALUSrcA = 2'd1;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD;
        end
        else if(STATE == LW)
        begin
           //  SizeHandler = 3'b100;
            MemToReg = 4'b0001;
            RegDest = 1'b0;
            RegWrite = 1'b1;

            IorD = 1'b1;
        end
        else if(STATE == LB)
        begin
            MemToReg = 4'b0010;
            RegDest = 1'b0;
            RegWrite = 1'b1;

            IorD = 1'b1;
        end
       

        // INSTRUÃÃES J
        else if(STATE == JUMP)
        begin
            PCSource = 4'b0010;
            PCWrite = 1'b1;
        end
        else if(STATE == JAL)
        begin
            PCSource = 4'b0010;
            PCWrite = 1'b1;
            RegDest = 3'b010;
            MemToReg = 4'b0011;
            // MemWrite = 1'b1;
            RegWrite = 1'b1;
        end
        // TRATAMENTO DE ERROS
        else if(STATE == EXCEPTION)
        begin
            ExceptionOcurred = 1'b1;
            PCWrite = 1'b1;

            // SizeHandler = 3'b110; //EXCEPTION !!!
            
        end
        else if(STATE == INVALIDOP)
        begin
            Exception = 4'b0001;
            IorD = 1'b1;
            MemRead = 1'b1;
            ALUSrcA = 4'b0000;
            ALUSrcB = 4'b0001;
            ALUControl = ALUSUB;
            EPCWrite = 1'b1;
        end
        else if(STATE == OVERFLOW)
        begin
            Exception = 4'b0010;
            IorD = 1'b1;
            MemRead = 1'b1;
            ALUSrcA = 4'b0000;
            ALUSrcB = 4'b0001;
            ALUControl = ALUSUB;
            EPCWrite = 1'b1;
        end
        else if(STATE == DIVBY0)
        begin
            Exception = 4'b0011;
            IorD = 1'b1;
            MemRead = 1'b1;
            ALUSrcA = 4'b0000;
            ALUSrcB = 4'b0001;
            ALUControl = ALUSUB;
            EPCWrite = 1'b1;
        end

    end


endmodule
