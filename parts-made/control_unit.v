module control_unit(
    input wire                  clk,
    input wire                  reset,
    
    // flags
    input wire                  ALUoverFlow,
    input wire                  Negativo,
    input wire                  Zero,
    input wire                  Igual,
    input wire                  Maior,
    input wire                  Menor,
    input wire                  Multoverflow,
    input wire                  DivByZero,

    // OPCODE
    input wire      [5:0]       OPCODE,
    
    //CONTROL SIGNALS

    output reg                  MemWrite,
    output reg                  PCwrite,
    output reg                  MemRead,
    output reg                  IRWrite,
    output reg                  RegWrite,
    output reg      [2:0]       MemToReg,
    output reg                  RegDest,
    output reg                  ALUSrcA,
    output reg                  EPCWrite,
    output reg                  IorD,
    output reg                  HIWrite,
    output reg                  LOWrite,
    output reg                  DivMult,
    
    output reg                  ALUoutWrite,
    output reg                  ExceptionOcurred

    // CONTROL VECTORS

    output reg     [3:0]        WriteSrc,
    output reg     [3:0]        PCSource,
    output reg     [3:0]        ALUSrcB,
    output reg     [3:0]        Exception,
    output reg     [2:0]        ShiftControl,
    output reg     [2:0]        ALUControl,

    // reset signal
    output reg                  out_reset
);

// estados

    parameter RESET      =  0;
    parameter READINST   =  1;
    parameter PC_INC     =  2
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
    parameter MEMOCALC   = 04;
    parameter SW         = 44;
    parameter READMEM    = 45;
    parameter LW         = 46;
    parameter LH         = 47;
    parameter LB         = 48;
    parameter SH         = 49;
    parameter SB         = 50;
    parameter JUMP       = 51;
    parameter JAL        = 52;
    parameter EXEPTION   = 54;
    parameter INVALIDOP  = 55;
    parameter OVERFLOW   = 56;
    parameter DIVBY0     = 57;

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


    


    reg     [2:0]       COUNTER;
    integer STATE = 0;

    initial begin
    
    rst_out = 1'b1;

    end

always @(posedge clk, reset) begin
        if( reset == 1'b1 ) 
        begin
            estado = 0; 
            tempo = 0;
        end
        else
        begin
            // TRANSIÇÃO ENTRE OS ESTADOS
            if( estado == RESET )
            begin
                if(tempo == 0) tempo = 2;  //para esperar um ciclo ainda no reset, para gravar na memória
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            else if(overflowflag)          estado = OVERFLOW;
            else if(estado == READINST1) //estado = READINST2;
            begin 
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0)  estado = READINST2;
            end
            else if(estado == READINST2)   estado = DECODEINST;
            else if(estado == DECODEINST)
            begin
                //INSTRUÇÕES R
                if(opcode == 6'b000000)
                begin
                         if(funct == MFHI_FUNCT) estado = MFHI;    //mfhi  0x10
                    else if(funct == MFLO_FUNCT) estado = MFLO;    //mflo  0x12
                    else if(funct == SLT_FUNCT) estado = SLT;     //slt   0x2a
                    else if(funct == SUB_FUNCT) estado = SUB;     //sub   0x22
                    else if(funct == ADD_FUNCT) estado = ADD;     //add   0x20
                    else if(funct == AND_FUNCT) estado = AND;     //and   0x24
                    else if(funct == DIV_FUNCT) estado = DIV;     //div   0x1a
                    else if(funct == MULT_FUNCT) estado = MULT;    //mul   0x18
                    else if(funct == JR_FUNCT) estado = JR;      //JR    0x8
                    else if(funct == SRA_FUNCT) estado = LOADSHFT;//SRA   0x3
                    else if(funct == SLL_FUNCT) estado = LOADSHFT;//SLL   0x0
                    else if(funct == DIVM_FUNCT) estado = DIVM;     //DIVM  0x1
                    //else if(funct == ) estado = LOADSHFTV;//SRAV  0x7                  TESTBENCH
                    //else if(funct == ) estado = LOADSHFTV;//SLLV  0x4                  TESTBENCH
                    //else if(funct == ) estado = LOADSHFT;//SRL   0x2                   TESTBENCH
                    //else if(funct == ) estado = BREAK;   //break 0xd
                    //else if(funct == ) estado = RTE;     //rte   0x13
                    //else if(funct == ) estado = LOADA;   //xchg  0x5
                    //else if(funct == ) estado = OR;      //or    0x25
                    else estado = INVALIDOP;
                end
                // INSTRUÇÕES I
                else if(opcode == ADDI_OPCODE) estado = ADDI;     //ADDI  0x8
                else if(opcode == LUI_OPCODE) estado = LOADSLUI; //LUI   0xf
                else if(opcode == BEQ_OPCODE) estado = BRNCHCALC;//BEQ   0x4
                else if(opcode == BNE_OPCODE) estado = BRNCHCALC;//BNE   0x5
                else if(opcode == LW_OPCODE) estado = MEMOCALC; //LW    0x23
                else if(opcode == LB_OPCODE) estado = MEMOCALC; //LB    0x20
                else if(opcode == SW_OPCODE) estado = MEMOCALC; //SW    0x2b
                else if(opcode == SB_OPCODE) estado = MEMOCALC; //SB    0x28
                //else if(opcode == ) estado = ADDIU;    //ADDIU 0x9
                //else if(opcode == ) estado = SLTI;     //SLTI  0xa
                //else if(opcode == ) estado = BRNCHCALC;//BLE   0x6
                //else if(opcode == ) estado = BRNCHCALC;//BGT   0x7
                //else if(opcode == ) estado = MEMOCALC; //LH    0x21
                //else if(opcode == ) estado = MEMOCALC; //SH    0x29
                // INSTRUÇÕES J
                //else if(opcode == 6'b000010) estado = JUMP;     //J     0x2            TESTBENCH
                //else if(opcode == 6'b000011) estado = JAL;      //JAL   0x3            TESTBENCH
                else estado = INVALIDOP;
            end
            // INSTRUÇÕES R - TRANSIÇÕES
            else if(estado == SLT)     estado = SAVEREGRD;//SAVELT;
            else if(estado == SUB)     estado = SAVEREGRD;//SAVEALU;
            else if(estado == ADD)     estado = SAVEREGRD;//SAVEALU;
            else if(estado == AND)     estado = SAVEREGRD;//SAVEALU;
            else if(estado == OR)      estado = SAVEREGRD;//SAVEOR;
            else if(estado == JR)      estado = SAVEPC;
            else if(estado == SAVEPC)  estado = READINST1;
            else if(estado == SAVEPCBK)estado = READINST1;
            else if(estado == LOADSHFT)
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0)
                begin
                         if(funct == SRA_FUNCT) estado = SRA;   //SRA   0x3
                    else if(funct == SLL_FUNCT) estado = SLL;   //SLL   0x0
                    //else if(funct == ) estado = SRL;   //SRL   0x2
                    else estado = INVALIDOP;
                end
            end
            // TESTBENCH
            // else if(estado == LOADSHFTV)
            // begin
            //     if(tempo == 0) tempo = 2;
            //     tempo = tempo - 1;
            //     if(tempo == 0)
            //     begin
            //              if(funct == 6'b000100) estado = SLLV;  //SLLV  0x4
            //         else if(funct == 6'b000111) estado = SRAV;  //SRAV  0x7
            //         else estado = INVALIDOP;
            //     end
            // end
            else if(/*estado == SLLV || estado == SRAV || estado == SRL */|| estado == SRA || estado == SLL) //todos os shift tipo R
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = SAVEREGRD;
            end
            else if(estado == MFHI)    estado = SAVEREGRD;
            else if(estado == MFLO)    estado = SAVEREGRD;
            else if(estado == SAVEREGRD)estado= READINST1;
            // else if(estado == BREAK)   estado = SAVEPCBK;
            //else if(estado == RTE)     estado = READINST1;
            else if(estado == DIV || estado == MULT)
            begin
                if(tempo == 0) tempo = 34; //espera 32 ciclos para completar a divisão/multiplicação
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
                if(divby0flag)begin tempo = 0; estado = DIVBY0; end
            end
            // else if(estado == LOADA)   //xchg load a
            // begin
            //     if(tempo == 0) tempo = 2;
            //     tempo = tempo - 1;
            //     if(tempo == 0) estado = LOADB;
            // end
            // else if(estado == LOADB)  //xchg load b
            // begin
            //     if(tempo == 0) tempo = 2;
            //     tempo = tempo - 1;
            //     if(tempo == 0) estado = ATOB;
            // end
            // else if(estado == ATOB)    estado = BTOA;
            // else if(estado == BTOA)    estado = READINST1;
            // INSTRUÇÕES I - TRANSIÇÕES
            else if(estado == ADDI)    estado = SAVEREGRT;
            // else if(estado == ADDIU)   estado = SAVEREGRT;
            // else if(estado == SLTI)    estado = SAVEREGRT;
            else if(estado == LOADSLUI)
            begin
                 if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = LUI;
            end
            else if(estado == LUI)     //estado = SAVEREGRT;
            begin
                 if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = SAVEREGRT;
            end
            else if(estado == SAVEREGRT)estado= READINST1;
            else if(estado == DIVM)
            begin 
                if(tempo == 0) tempo = 34;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
                if(divby0flag)begin tempo = 0; estado = DIVBY0; end
            end
            else if(estado == BRNCHCALC)
            begin
                     if(opcode == 6'b000100) estado = BEQ;//BEQ   0x4
                else if(opcode == 6'b000101) estado = BNE;//BNE   0x5
                // else if(opcode == 6'b000110) estado = BLE;//BLE   0x6
                // else if(opcode == 6'b000111) estado = BGT;//BGT   0x7
            end
            else if(estado == BEQ)        estado = CONDSAVEPC;
            else if(estado == BNE)        estado = CONDSAVEPC;
            // else if(estado == BLE)        estado = CONDSAVEPC;
            // else if(estado == BGT)        estado = CONDSAVEPC;
            else if(estado == CONDSAVEPC) estado = READINST1;
            else if(estado == MEMOCALC)
            begin
                if(opcode ==  SW_OPCODE) estado = SW;  // SW 0x2b
                else estado = READMEM;  // SH/SB/LW/LH/LB
            end
            else if(estado == READMEM) 
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0)
                begin
                         if(opcode == 6'b100011) estado = LW;  //LW    0x23
                    else if(opcode == 6'b100000) estado = LB;  //LB    0x20
                    else if(opcode == 6'b101000) estado = SB;  //SB    0x28
                    // else if(opcode == 6'b100001) estado = LH;  //LH    0x21
                    // else if(opcode == 6'b101001) estado = SH;  //SH    0x29
                end
            end
            else if(estado == LW)
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            // else if(estado == LH)// estado = READINST1;
            // begin
            //     if(tempo == 0) tempo = 2;
            //     tempo = tempo - 1;
            //     if(tempo == 0) estado = READINST1;
            // end
            else if(estado == LB)// estado = READINST1;
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            else if(estado == SW) estado = READINST1;
            else if(estado == SB) estado = READINST1;
            else if(estado == LB) estado = READINST1;
            // else if(estado == SH) estado = READINST1;
            // INSTRUÇÕES J - TRANSIÇÃO
            else if(estado == JUMP) estado = READINST1;
            // else if(estado == JAL)  //estado = READINST1;             TESTBENCH
            // begin
            //     if(tempo == 0) tempo = 1;
            //     tempo = tempo - 1;
            //     if(tempo == 0) estado = READINST1;
            // end
            // TRATAMENTOS DE ERROS
            else if(estado == EXEPTION) // estado = READINST1;
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            else if(estado == INVALIDOP) // estado = EXEPTION;
            begin
                if(tempo == 0) tempo = 6;
                tempo = tempo - 1;
                if(tempo == 0) estado = EXEPTION;
            end
            else if(estado == DIVBY0)   // estado = EXEPTION;
            begin
                if(tempo == 0) tempo = 6;
                tempo = tempo - 1;
                if(tempo == 0) estado = EXEPTION;
            end
            else if(estado == OVERFLOW)
            begin
                if(tempo == 0) tempo = 6;
                tempo = tempo - 1;
                if(tempo == 0) estado = EXEPTION;
            end
        end
    end


    parameter ALULOAD       = 3'b000; 
    parameter ALUOADD       = 3'b001;
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


        always @(estado) begin

        MemWrite = 1'b0;
        PCwrite = 1'b0;
        MemRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        RegDest = 1'b0;
        ALUSrcA = 1'b0;
        EPCWrite = 1'b0;
        IorD = 1'b0;
        HIWrite = 1'b0;
        LOWrite = 1'b0;
        DivMult = 1'b0;
        
        ALUoutWrite = 1'b0;
        ExceptionOcurred = 1'b0;

        MemToReg = 3'b000;
        WriteSrc = 3'b0;
        PCSource = 3'b0;
        ALUSrcB = 3'b0;
        Exception = 3'b0;
        ShiftControl = 2'b0;
        ALUControl = 2'b0;


        if(estado == RESET)
        begin
            RegDest  = 3'b011; // seleciona o $29
            MemToReg = 3'b010; // seta o $29 como 227
            RegWrite = 1'b1;   // escreve no banco
        end
        else if(estado == READINST1)
        begin
            
            IorD    = 1'b0;    // seleciona o endereço do pc p/ o mux
            // Exception = 3'b000;
            MemRead = 1'b1; // memória lê automaticamente
        end
        else if(estado == READINST2)
        begin
            ALUSrcA = 2'd0;   
            ALUSrcB = 3'b001; 
            ALUControl = ALUADD;
            PCWrite = 1'b1;
            PCSource = 3'b000;
            PCin    = 1'b0; 
        end
        else if(estado == DECODEINST)
        begin
            IRWrite = 1'b1; 
            // PCWrite = 1'b1; // !!! Adicionado !!!
            // IRWrite = 1'b1; // !!! cuidado !!!
        end
        // INSTRUÇÕES R
        else if(estado == SLT)
        begin
            ALUSrcA = = 1'b1;
            ALUSrcB  = 3'b000;
            ALUControl = ALUCMP;  // S = X comp Y
        end
        else if(estado == SUB)
        begin
            ALUSrcA = 1'b1;
            ALUSrcB  = 3'b000;
            ALUControl = ALUSUB; // S = X - Y
        end
        else if(estado == ADD)
        begin
            ALUSrcA = 1'b1;
            ALUSrcB = 3'b000;
            ALUControl = ALUADD; // soma COM OVERFLOW
        end
        else if(estado == AND)
        begin
            ALUSrcA = 1'b1;
            ALUSrcB  = 3'b000;
            ALUControl = ALUAND;
        end
        // else if(estado == OR)
        // begin
        //     ALUSrcA = 1'b1;
        //     ALUSrcB = 3'b000;
        //     ALUControl = ALUOR;
        // end
        else if(estado == DIV)
        begin
            ALUSrcA = 1'b1;
            ALUSrcB  = 3'b000;
            DivMult = 1'b0;
            HIWrite = 1'b1;
            LOWrite = 1'b1;

        end
        else if(estado == MULT)
        begin
            ALUSrcA = 1'b1;
            ALUSrcB  = 3'b000;
            DivMult = 1'b1;
            HIWrite = 1'b1;
            LOWrite = 1'b1;
        end
        else if(estado == JR)
        begin
            ALUSrcA = 1'b1;
            ALUSrcB  = 3'b000;
            ALUControl = ALULOAD;
            PCSource = 3'b001;
            PCin = 1'b0;
            PCWrite = 1'b1;
        end
        else if(estado == SAVEPC)
        begin
            PCSource = 3'b001;
            PCWrite  = 1'b1;
        end
        else if(estado == SAVEPCBK)
        begin
            PCSource = 3'b010;
            PCWrite  = 1'b1;
        end
        else if(estado == LOADSHFT)
        begin
            // ALUSrcA = 2'd1;
            // ALUSrcB  = 3'b000;
            // SLLSourceA = 2'b10; //Entrada A é o B !!!
            // SLLSourceB = 2'b10; //Entrada B é o SHAMT !!!
            ShiftControl = 3'b001;
            // ALUControl = ALUSFT;
        end
        // else if(estado == LOADSHFTV)
        // begin
        //     // ALUSrcA = 2'd1;
        //     // ALUSrcB  = 3'b000;
        //     // SLLSourceA = 2'b00; //Entrada A é o A !!!
        //     // SLLSourceB = 2'b00; //Entrada B é o B !!!
        //     ShiftControl = 3'b001;
        //     // ALUControl = ALUSFT;
        // end
        // else if(estado == SLLV)
        // begin
        //     // ALUSrcA = 2'd1;
        //     // ALUSrcB  = 3'b000;
        //     // SLLSourceA = 2'b00;
        //     // SLLSourceB = 2'b00; //
        //     ShiftControl = 3'b010;
        //     // ALUControl = ALUSFT;
        // end
        // else if(estado == SRAV)
        // begin
        //     ALUSrcA = 2'd1;
        //     ALUSrcB  = 3'b000;
        //     SLLSourceA = 2'b00;
        //     SLLSourceB = 2'b00;
        //     ShiftControl = 3'b100;
        //     ALUControl = ALUSFT;
        // end
        else if(estado == SRA)
        begin
            // ALUSrcA = 2'd1;
            // ALUSrcB  = 3'b000;
            // SLLSourceA = 2'b10;
            // SLLSourceB = 2'b10;
            ShiftControl = 3'b100;
            // ALUControl = ALUSFT;
        end
        // else if(estado == SRL) //        TODO TESTBENCH
        // begin
        //     // ALUSrcA = 2'd1;
        //     // ALUSrcB  = 3'b000;
        //     // SLLSourceA = 2'b10;
        //     // SLLSourceB = 2'b10;
        //     ShiftControl = 3'b011;
        //     // ALUControl = ALUSFT;
        // end
        else if(estado == SLL)
        begin
            // ALUSrcA = 2'd1;
            // ALUSrcB  = 3'b000;
            // SLLSourceA = 2'b10; //!!! Entrada é o B
            // SLLSourceB = 2'b10;
            ShiftControl = 3'b010;
            // ALUControl = ALUSFT;
        end
        else if(estado == MFHI)
        begin
            RegWrite = 1'b0;
            MemtoReg = 3'b000;
            WriteSrc = 3'b000;
            RegDest  = 3'b001;
        end
        else if(estado == MFLO)
        begin
            RegWrite = 1'b0;
            MemtoReg = 3'b000;
            WriteSrc = 3'b010;
            RegDest  = 3'b001;
        end
        else if(estado == SAVEREGRD)
        begin
            RegWrite = 1'b1; 
            RegDest = 3'b001;
            WriteSrc = 3'b001
            MemToReg = 3'b000;
        end
        // else if(estado == BREAK)
        // begin
        //     ALUSrcA = 2'd0;
        //     ALUSrcB = 3'b001;
        //     ALUControl = ALUSUB;
        // end
        // else if(estado == RTE)
        // begin
        //     PCSource = 3'b100;
        //     PCWrite = 1'b1;
        // end
        // else if(estado == LOADA)
        // begin
        //     Exception = 3'b100; // Lê da memória na posição de A
        //     SizeHandler = 3'b100;
        // end
        // else if(estado == LOADB)
        // begin
        //     SizeHandler = 3'b111;
        //     SaveTemp = 1'b1;
        //     Exception = 3'b101;
        //     // Lê a memória no posição B e salva o A em Temp
        // end
        // else if(estado == ATOB)
        // begin
        //     SizeHandler = 3'b111;
        //     DataSource = 1'b0;
        //     Exception = 3'b101;   // Salva A na pos de B
        //     MemWrite = 1'b1;
        // end
        // else if(estado == BTOA)
        // begin
        //     SizeHandler = 3'b111;
        //     DataSource = 1'b1;
        //     Exception = 3'b100;   // Salva B na pos de A
        //     MemWrite = 1'b1;
        // end




        // INSTRUIÇÕES I
        else if(estado == ADDI)
        begin
            ALUSrcA = 3'b001;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD; //soma com overflow
        end
        // else if(estado == ADDIU)
        // begin
        //     ALUSrcA = 2'd1;
        //     ALUSrcB = 3'b010;
        //     ALUControl = ALUSADD;  // soma sem overflow
        // end
        // else if(estado == SLTI)
        // begin
        //     ALUSrcA = 2'd1;
        //     ALUSrcB = 3'b010;
        //     ALUControl = ALUCMP;
        // end
        // else if(estado == DIVM) // TODO
        // begin
        //     ALUSrcA = 2'd2;
        //     ALUSrcB = 3'b010;
        //     ALUControl = ALUDIV;
        // end
        else  if(estado == LOADSLUI)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB  = 3'b000;
            SLLSourceA = 2'b01; //!!! Entrada é o imediato
            SLLSourceB = 2'b01;
            ShiftControl = 3'b001;
            ALUControl = ALUSFT;
        end
        else if(estado == LUI)
        begin
            SLLSourceA = 2'b01; //!!! Entrada é o imediato
            SLLSourceB = 2'b01;
            ShiftControl = 3'b010;
            ALUControl = ALUSFT; //shift
        end
        else if(estado == SAVEREGRT)
        begin
            MemToReg = 3'b000;
            RegWrite = 1'b1;
            RegDest = 3'b000;
            WriteSrc = 3'b001;
        end
        else if(estado == BRNCHCALC)
        begin
            ALUSrcA = 2'd0;   //seleciona o PC
            ALUSrcB = 3'b011; //+4  // calcula o novo PC após o branch
            ALUControl = ALUADD; // soma com overflow
        end
        else if(estado == BEQ)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB = 3'b000;
            ALUControl = ALUEQ;
            PCWrite = 1'b1;
            tempo = 1;
        end
        else if(estado == BNE)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB = 3'b000;
            ALUControl = ALUNE;   
            PCWrite = 1'b1;
            tempo = 1;
        end
        else if(estado == BLE)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB = 3'b000;
            ALUControl = ALULE;
            PCWrite = 1'b1;
            tempo = 1;
        end
        // else if(estado == BGT)
        // begin
        //     ALUSrcA = 2'd1;
        //     ALUSrcB = 3'b000;
        //     ALUControl = ALUGT;
        //     PCWriteCond = 1'b1;
        //     tempo = 1;
        // end
        else if(estado == CONDSAVEPC)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB = 3'b000;   //mantem a entrada
            PCSource = 3'b010;
            tempo = 0;
        end
        else if(estado == MEMOCALC)
        begin
            ALUSrcA = 2'd1;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD; // soma com overflow p/ saber pos da memória
        end
        else if(estado == SW)
        begin
            IorD = 1'b1;
            Exception = 3'b000;
            SizeHandler =3'b001;
            DataSource = 1'b1;
            MemWrite = 1'b1;

            ALUSrcA = 2'd1;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD;
        end
        else if(estado == READMEM)
        begin
            IorD = 1'b1;
            Exception = 3'b000; //Lê da memória na pos calculada em MEMOCALC

            ALUSrcA = 2'd1;
            ALUSrcB = 3'b010;
            ALUControl = ALUADD;
        end
        else if(estado == LW)
        begin
            SizeHandler = 3'b100;
            MemToReg = 3'b001;
            RegDest = 1'b0;
            RegWrite = 1'b1;

            IorD = 1'b1;
            Exception = 3'b000;
        end
        // else if(estado == LH)
        // begin
        //     SizeHandler = 3'b101;
        //     MemToReg = 3'b001;
        //     RegDest = 1'b0;
        //     RegWrite = 1'b1;

        //     IorD = 1'b1;
        //     Exception = 3'b000;
        // end
        // else if(estado == LB)
        // begin
        //     // SizeHandler = 3'b011;
        //     MemToReg = 3'b001;
        //     RegDest = 1'b0;
        //     RegWrite = 1'b1;

        //     IorD = 1'b1;
        //     Exception = 3'b000;
        // end
        // else if(estado == SH)
        // begin
        //     // SizeHandler = 3'b010;
        //     DataSource = 1'b1;
        //     MemWrite = 1'b1;

        //     IorD = 1'b1;
        //     Exception = 3'b000;
        // end
        // else if(estado == SB)
        // begin
        //     SizeHandler = 3'b000;
        //     DataSource = 1'b1;
        //     MemWrite = 1'b1;

        //     IorD = 1'b1;
        //     Exception = 3'b000;
        // end
        // INSTRUÇÕES J
        else if(estado == JUMP)
        begin
            PCSource = 2'b00;
            PCWrite = 1'b1;
        end
        else if(estado == JAL)
        begin
            PCSource = 2'b00;
            PCWrite = 1'b1;
            RegDest = 3'b010;
            MemToReg = 3'b100;
            // MemWrite = 1'b1;
            RegWrite = 1'b1;
        end
        // TRATAMENTO DE ERROS
        else if(estado == EXEPTION)
        begin
            MemToReg = 3'b000;
            RegDest = 3'b011;
            // SizeHandler = 3'b110; //Exeption !!!
            PCSource = 3'b011;
            PCWrite = 1'b1;
            ExceptionOcurred = 1'b1;
        end
        else if(estado == INVALIDOP)
        begin
            Exception = 3'b001;
            // !!!
            MemToReg = 3'b000;
            RegDest = 3'b011;
            // SizeHandler = 3'b110; //Exeption !!!
            PCSource = 3'b011;
            // PCWrite = 1'b1;

            EPCWrite = 1'b1;
            ALUSrcA = 2'd0;
            ALUSrcB = 3'b001;
            ALUControl = ALUSUB;
        end
        else if(estado == OVERFLOW)
        begin
            Exception = 3'b010;
            MemToReg = 3'b000;
            RegDest = 3'b011;
            // SizeHandler = 3'b110; //Exeption !!!
            PCSource = 3'b011;
            
            EPCWrite = 1'b1;
            ALUSrcA = 2'd0;
            ALUSrcB = 3'b001;
            ALUControl = ALUSUB;
        end
        else if(estado == DIVBY0)
        begin
            Exception = 3'b011;
            MemToReg = 3'b000;
            RegDest = 3'b011;
            // SizeHandler = 3'b110; //Exeption !!!
            PCSource = 3'b011;
            // PCWrite = 1'b1;
            
            EPCWrite = 1'b1;
            ALUSrcA = 2'd0;
            ALUSrcB = 3'b001;
            ALUControl = ALUSUB;
        end

    end


endmodule

