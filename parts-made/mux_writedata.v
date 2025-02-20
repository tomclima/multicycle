module mux_writedata(
    input wire      [3:0]       selector,
    input wire      [31:0]      write_src_mux_out,
    input wire      [31:0]      mem_out,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? write_src_mux_out : 
                  (selector == 4'b0001) ? mem_out: 
                  (selector == 4'b0010) ? 32'd227 : 32'b0;  // Default case

endmodule
