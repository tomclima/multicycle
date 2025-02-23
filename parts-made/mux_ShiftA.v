module mux_ShiftA(
    input wire      [3:0]       ShiftSourceA,
    input wire      [4:0]       SHAMT,
    input wire      [31:0]      Aout,      
    output wire     [4:0]       data_out
);

assign data_out = (ShiftSourceA == 4'b0000) ? SHAMT : 
                  (ShiftSourceA == 4'b0001) ?  5'b10000 :
                  (ShiftSourceA == 4'b0010) ? Aout[5:0] : 5'b00000; //default

endmodule
