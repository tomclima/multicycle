module mux_aluA(
    input   wire            selector,
    input   wire    [31:0]  data_0,
    input   wire    [31:0]  data_1,
    output  wire    [31:0]  data_out
);

    assign data_out = selector ? data_0 : data_1;

endmodule;