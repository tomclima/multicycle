module mux_ShiftB(
    input wire      [3:0]       selector,
    input wire      [31:0]      Bout,
    input wire      [15:0]      IMMEDIATE,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? Bout : 
                  (selector == 4'b0001) ? {{16'b0} , OFFSET} : 32'b0;  // Default case

endmodule
