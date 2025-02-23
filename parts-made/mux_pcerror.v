module mux_pcerror(
    input   wire            selector,
    input   wire    [31:0]  pc_source_out,
    input   wire    [31:0]  pc_exception,
    output  wire    [31:0]  data_out
);

    assign data_out = selector ? pc_exception : pc_source_out;

endmodule;