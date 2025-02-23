module mux_writesrc(
    input wire      [3:0]       selector,
    input wire      [31:0]      ALUout,
    input wire      [31:0]      Hiout,
    input wire      [31:0]      Loout,
    input wire      [31:0]      Shiftout,
    input wire      [31:0]      SLTout,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? ALUout : 
                  (selector == 4'b0001) ? Hiout : 
                  (selector == 4'b0010) ? Loout : 
                  (selector == 4'b0011) ? Shiftout : 
                  (selector == 4'b0100) ? SLTout : 32'b0;  // Default case

endmodule
