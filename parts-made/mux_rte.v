module mux_rte(
    input   wire            selector,
    input   wire    [31:0]  pc_source_out,
    input   wire    [31:0]  EPC,
    output  wire    [31:0]  data_out
);

    assign data_out = selector ? EPC : pc_source_out;

endmodule;