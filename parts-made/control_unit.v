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
    output reg                  MemToReg,
    output reg                  RegDest,
    output reg                  AluSRCA,
    output reg                  EPCWrite,
    output reg                  IorD,
    output reg                  HIWrite,
    output reg                  LOWrite,
    output reg                  DivMult,
    output reg                  ABWrite,
    output reg                  ALUoutWrite,

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
                         if(funct == 6'b010000) estado = MFHI;    //mfhi  0x10
                    else if(funct == 6'b010010) estado = MFLO;    //mflo  0x12
                    else if(funct == 6'b001101) estado = BREAK;   //break 0xd
                    else if(funct == 6'b010011) estado = RTE;     //rte   0x13
                    else if(funct == 6'b000101) estado = LOADA;   //xchg  0x5
                    else if(funct == 6'b101010) estado = SLT;     //slt   0x2a
                    else if(funct == 6'b100010) estado = SUB;     //sub   0x22
                    else if(funct == 6'b100000) estado = ADD;     //add   0x20
                    else if(funct == 6'b100100) estado = AND;     //and   0x24
                    else if(funct == 6'b100101) estado = OR;      //or    0x25
                    else if(funct == 6'b011010) estado = DIV;     //div   0x1a
                    else if(funct == 6'b011000) estado = MULT;    //mul   0x18
                    else if(funct == 6'b001000) estado = JR;      //JR    0x8
                    else if(funct == 6'b000100) estado = LOADSHFTV;//SLLV  0x4
                    else if(funct == 6'b000111) estado = LOADSHFTV;//SRAV  0x7
                    else if(funct == 6'b000011) estado = LOADSHFT;//SRA   0x3
                    else if(funct == 6'b000010) estado = LOADSHFT;//SRL   0x2
                    else if(funct == 6'b000000) estado = LOADSHFT;//SLL   0x0
                    else estado = INVALIDOP;
                end
                // INSTRUÇÕES I
                else if(opcode == 6'b001000) estado = ADDI;     //ADDI  0x8
                else if(opcode == 6'b001001) estado = ADDIU;    //ADDIU 0x9
                else if(opcode == 6'b001010) estado = SLTI;     //SLTI  0xa
                else if(opcode == 6'b000001) estado = DIVM;     //DIVM  0x1
                else if(opcode == 6'b001111) estado = LOADSLUI; //LUI   0xf
                else if(opcode == 6'b000100) estado = BRNCHCALC;//BEQ   0x4
                else if(opcode == 6'b000101) estado = BRNCHCALC;//BNE   0x5
                else if(opcode == 6'b000110) estado = BRNCHCALC;//BLE   0x6
                else if(opcode == 6'b000111) estado = BRNCHCALC;//BGT   0x7
                else if(opcode == 6'b100011) estado = MEMOCALC; //LW    0x23
                else if(opcode == 6'b100001) estado = MEMOCALC; //LH    0x21
                else if(opcode == 6'b100000) estado = MEMOCALC; //LB    0x20
                else if(opcode == 6'b101011) estado = MEMOCALC; //SW    0x2b
                else if(opcode == 6'b101001) estado = MEMOCALC; //SH    0x29
                else if(opcode == 6'b101000) estado = MEMOCALC; //SB    0x28
                // INSTRUÇÕES J
                else if(opcode == 6'b000010) estado = JUMP;     //J     0x2
                else if(opcode == 6'b000011) estado = JAL;      //JAL   0x3
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
                         if(funct == 6'b000011) estado = SRA;   //SRA   0x3
                    else if(funct == 6'b000010) estado = SRL;   //SRL   0x2
                    else if(funct == 6'b000000) estado = SLL;   //SLL   0x0
                    else estado = INVALIDOP;
                end
            end
            else if(estado == LOADSHFTV)
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0)
                begin
                         if(funct == 6'b000100) estado = SLLV;  //SLLV  0x4
                    else if(funct == 6'b000111) estado = SRAV;  //SRAV  0x7
                    else estado = INVALIDOP;
                end
            end
            else if(estado == SLLV || estado == SRAV || estado == SRA || estado == SRL || estado == SLL) //todos os shift tipo R
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = SAVEREGRD;
            end
            else if(estado == MFHI)    estado = SAVEREGRD;
            else if(estado == MFLO)    estado = SAVEREGRD;
            else if(estado == SAVEREGRD)estado= READINST1;
            else if(estado == BREAK)   estado = SAVEPCBK;
            else if(estado == RTE)     estado = READINST1;
            else if(estado == DIV || estado == MULT)
            begin
                if(tempo == 0) tempo = 34; //espera 32 ciclos para completar a divisão/multiplicação
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
                if(divby0flag)begin tempo = 0; estado = DIVBY0; end
            end
            else if(estado == LOADA)   //xchg load a
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = LOADB;
            end
            else if(estado == LOADB)  //xchg load b
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = ATOB;
            end
            else if(estado == ATOB)    estado = BTOA;
            else if(estado == BTOA)    estado = READINST1;
            // INSTRUÇÕES I - TRANSIÇÕES
            else if(estado == ADDI)    estado = SAVEREGRT;
            else if(estado == ADDIU)   estado = SAVEREGRT;
            else if(estado == SLTI)    estado = SAVEREGRT;
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
                else if(opcode == 6'b000110) estado = BLE;//BLE   0x6
                else if(opcode == 6'b000111) estado = BGT;//BGT   0x7
            end
            else if(estado == BEQ)        estado = CONDSAVEPC;
            else if(estado == BNE)        estado = CONDSAVEPC;
            else if(estado == BLE)        estado = CONDSAVEPC;
            else if(estado == BGT)        estado = CONDSAVEPC;
            else if(estado == CONDSAVEPC) estado = READINST1;
            else if(estado == MEMOCALC)
            begin
                if(opcode ==  6'b101011) estado = SW;  // SW 0x2b
                else estado = READMEM;  // SH/SB/LW/LH/LB
            end
            else if(estado == READMEM) 
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0)
                begin
                         if(opcode == 6'b100011) estado = LW;  //LW    0x23
                    else if(opcode == 6'b100001) estado = LH;  //LH    0x21
                    else if(opcode == 6'b100000) estado = LB;  //LB    0x20
                    else if(opcode == 6'b101001) estado = SH;  //SH    0x29
                    else if(opcode == 6'b101000) estado = SB;  //SB    0x28
                end
            end
            else if(estado == LW)
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            else if(estado == LH)// estado = READINST1;
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            else if(estado == LB)// estado = READINST1;
            begin
                if(tempo == 0) tempo = 2;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
            else if(estado == SW) estado = READINST1;
            else if(estado == SH) estado = READINST1;
            else if(estado == SB) estado = READINST1;
            else if(estado == LB) estado = READINST1;
            // INSTRUÇÕES J - TRANSIÇÃO
            else if(estado == JUMP) estado = READINST1;
            else if(estado == JAL)  //estado = READINST1;
            begin
                if(tempo == 0) tempo = 1;
                tempo = tempo - 1;
                if(tempo == 0) estado = READINST1;
            end
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
    

endmodule