module mux_pcsource(
    input wire      [3:0]       selector,
    input wire      [31:0]      data_0,
    input wire      [31:0]      data_2,
    input wire      [31:0]      data_3,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? data_0 : 
                  (selector == 4'b0001) ? 4 : 
                  (selector == 4'b0010) ? data_2 : 
                  (selector == 4'b0011) ? data_3 : 32'b0;  // Default case

endmodule
