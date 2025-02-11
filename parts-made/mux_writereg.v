module mux_writereg(
    input   wire                selector,
    input   wire        [15:0]  data_0,
    input   wire        [4:0]   data_1,
    output  wire        [4:0]   data_out
);

    assign data_out = selector ? data_0[15:11], data_1;

endmodule