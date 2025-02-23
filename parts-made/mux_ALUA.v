module mux_ALUA(
    input   wire    [3:0]   selector,
    input   wire    [31:0]  data_0,
    input   wire    [31:0]  data_1,
    input   wire    [31:0]  data_2,
    output  wire    [31:0]  data_out
);

    assign data_out = (selector == 4'b0000) ? data_0 : 
                  (selector == 4'b0001) ? data_1 : 
                  (selector == 4'b0010) ? data_2 : 32'b0;  // Default case

endmodule;