module mux_IorD(
    input   wire            selector,
    input   wire    [31:0]  pc_out,
    input   wire    [31:0]  mem_exc_mux_out,
    output  wire    [31:0]  data_out
);

    assign data_out = selector ? pc_out, mem_exc_mux_out;

endmodule;