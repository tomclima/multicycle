module mul_exception (
    input   wire    [3:0]       selector,
    input   wire    [31:0]      ALUout,
    output  wire    [31:0]      out
);
    
assign data_out = (selector == 4'b0000) ? ALUout : 
                  (selector == 4'b0001) ? 32'd253 : 
                  (selector == 4'b0010) ? 32'd254 : 
                  (selector == 4'b0011) ? 32'255 : 32'b0;  // Default case


endmodule