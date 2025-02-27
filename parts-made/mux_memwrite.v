module mux_memwrite(
    input wire      [3:0]       selector,
    input wire      [31:0]      Bout,
    output wire     [31:0]      data_out
);

assign data_out = (selector == 4'b0000) ? Bout : 
                  (selector == 4'b0001) ? {{24'b0},Bout[7:0]} : 32'b0;  // Default case

endmodule
