module mux_ALUB(
    input wire      [3:0]       selector,
    input wire      [31:0]      Bout,
    input wire      [31:0]      SignExt,
    input wire      [31:0]      Shift2,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? Bout : 
                  (selector == 4'b0001) ? 32'd4 : 
                  (selector == 4'b0010) ? SignExt : 
                  (selector == 4'b0011) ? Shift2 : 32'b0;  // Default case

endmodule
