module mux_pcsource(
    input wire      [3:0]       selector,
    input wire      [31:0]      alu_result,
    input wire      [31:0]      alu_out,
    input wire      [31:0]      jump,
    input wire      [31:0]      exception,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? alu_result : 
                  (selector == 4'b0001) ? alu_out : 
                  (selector == 4'b0010) ? jump : 
                  (selector == 4'b0011) ? exception : 32'b0;  // Default case

endmodule
