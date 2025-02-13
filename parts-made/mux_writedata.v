module mux_writedata(
    input   wire            MemToReg,
    input   wire    [31:0]  write_src_mux_out,
    input   wire    [31:0]  byte_mux_out,
    output  wire    [31:0]  data_out
);

    assign data_out = selector ? data_0, data_1;

endmodule;