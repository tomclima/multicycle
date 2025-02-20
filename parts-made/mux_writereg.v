module mux_writereg(
    input wire      [3:0]       selector,
    input wire      [4:0]      data_0,
    input wire      [15:0]      data_1,
    output wire     [4:0]      data_out
);

assign data_out = (selector == 4'b0000) ? data_0 : 
                  (selector == 4'b0001) ? data_1 : 
                  (selector == 4'b0010) ? 32'd31 : 
                  (selector == 4'b0011) ? 32'd29 : 32'b0;  // Default case

endmodule
