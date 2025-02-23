module mux_exception (
    input   wire    [3:0]       selector,
    input   wire    [31:0]      ALUout,
    output  wire    [31:0]      data_out
);
    
assign data_out = (selector == 4'b0000) ? ALUout : 
                  (selector == 4'b0001) ? 32'b00000000000000000000000011111101 : 
                  (selector == 4'b0010) ? 32'b00000000000000000000000011111110 : 
                  (selector == 4'b0011) ? 32'b00000000000000000000000011111111 : 32'b0;  // Default case


endmodule