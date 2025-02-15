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

    always @(STATE) begin
    MemWrite = 1'b0;
    PCwrite = 1'b0;
    MemRead = 1'b0;
    IRWrite = 1'b0;
    RegWrite = 1'b0;
    MemToReg = 1'b0;
    RegDest = 1'b0;
    AluSRCA = 1'b0;
    EPCWrite = 1'b0;
    IorD = 1'b0;
    HIWrite = 1'b0;
    LOWrite = 1'b0;
    DivMult = 1'b0;
    ABWrite = 1'b0;
    ALUoutWrite = 1'b0;
    WriteSrc = 4'b0000;
    PCSource = 4'b0000;
    ALUSrcB = 4'b0000;
    Exception = 4'b0000;
    ShiftControl = 3'b000;
    ALUControl   = 3'b001;
    

    if(reset == 1'b1) begin
        if(STATE != RESET) begin
            STATE = RESET;
                MemWrite = 1'b0;
                PCwrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                MemToReg = 1'b0;
                RegDest = 1'b0;
                AluSRCA = 1'b0;
                EPCWrite = 1'b0;
                IorD = 1'b0;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                DivMult = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                WriteSrc = 4'b0000;
                PCSource = 4'b0000;
                ALUSrcB = 4'b0000;
                Exception = 4'b0000;
                ShiftControl = 3'b000;
                ALUControl   = 3'b001;

                rst_out = 1'b1;
                COUNTER = 3'b000;
        end
        else begin
                STATE = READINST;

            end 
        end
        else begin
            case (STATE)
                READINST : begin

                end
            
                PC_INC: begin
                STATE = DECODE;


                case (OPCODE)
                    R_OPCODE: begin
                        STATE = READ_REGBANK;
                    end
                    default : STATE = INVALIDOP;
                endcase
                    
                end
                READ_REGBANK : begin


                case (FUNCT)
                    ADD_FUNCT: begin
                        
                    end
                    default: 
                endcase
                end
                COMMON : begin
                    
                end
                COMMON : begin
                    
                end
                COMMON : begin
                    
                end
                default: 
            endcase
        end

    end

    

endmodule